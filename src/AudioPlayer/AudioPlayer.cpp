/*
 * AudioPlayer.cpp
 *
 *  Created on: 2018年8月1日
 *      Author: liuwanlin
 */

#include "AudioPlayer.hpp"
#include "../Misc/Misc.hpp"

#include <QObject>
#include <bb/multimedia/MediaPlayer>
#include <bb/multimedia/NowPlayingConnection>
#include <bb/multimedia/OverlayStyle>
#include <bb/multimedia/MediaState>
#include <bb/data/JsonDataAccess>
#include "../Misc/Misc.hpp"
#include "../Requester/Requester.hpp"

using namespace bb::multimedia;
using namespace bb::data;

QString AudioPlayer::albumInfoApi = "http://mobile.ximalaya.com/mobile/v1/album/track?albumId=%1&pageId=%2&pageSize=20&isAsc=%3";
int AudioPlayer::maxPlayLogSize = 60;

AudioPlayer::AudioPlayer() : bb::multimedia::MediaPlayer() {
    this->playTimer = new QTimer();
    this->exitTimer = new QTimer();

    this->exitTime = 0;
    this->currentExitTime = 0;
    this->requester = NULL;

    this->lastSavePositionTime = QDateTime::currentDateTime().toTime_t();

    connect(playTimer, SIGNAL(timeout()), this, SLOT(playTimerTimeout()));
    connect(exitTimer, SIGNAL(timeout()), this, SLOT(exitTimerTimeout()));

    nowPlayingConnection = new NowPlayingConnection(this);
    nowPlayingConnection->setOverlayStyle(OverlayStyle::Fancy);

    connect(nowPlayingConnection, SIGNAL(play()), this, SLOT(npPlay()));
    connect(nowPlayingConnection, SIGNAL(pause()), this, SLOT(npPause()));
    connect(nowPlayingConnection, SIGNAL(revoked()), this, SLOT(npRevoked()));
    connect(nowPlayingConnection, SIGNAL(previous()), this, SLOT(npPrevious()));
    connect(nowPlayingConnection, SIGNAL(next()), this, SLOT(npNext()));

    connect(this, SIGNAL(mediaStateChanged(bb::multimedia::MediaState::Type)), this, SLOT(mpMediaStateChanged(bb::multimedia::MediaState::Type)));
    connect(this, SIGNAL(durationChanged(unsigned int)), this, SLOT(mpDurationChanged(unsigned int)));
    connect(this, SIGNAL(positionChanged(unsigned int)), this, SLOT(mpPositionChanged(unsigned int)));
    connect(this, SIGNAL(playbackCompleted()), this, SLOT(mpPlaybackCompleted()));
}

void AudioPlayer::setPositionFromCache() {
    int position = Misc::getConfig("playPosition", "0").toInt();

    if(position == 0) {
        return;
    }

    // 用一次就清理
    Misc::setConfig("playPosition", "0");

    // 移动到相应位置播放
    this->seekTime(position);
}

void AudioPlayer::mpMediaStateChanged(bb::multimedia::MediaState::Type mediaState) {
    nowPlayingConnection->setMediaState(mediaState);
    if(mediaState == MediaState::Started) {
        nowPlayingConnection->acquire();
        // 设置开始播放位置
        this->setPositionFromCache();
    }else if(mediaState == MediaState::Stopped) {
        nowPlayingConnection->revoke();
    }

    qDebug() << "AudioPlayer::mpMediaStateChanged mediaState" << mediaState;
}
void AudioPlayer::mpDurationChanged(unsigned int duration) {
    nowPlayingConnection->setDuration(duration);
}
void AudioPlayer::mpPositionChanged(unsigned int position) {
    nowPlayingConnection->setPosition(position);

    this->updatePlayLogPosition(this->currentTrackInfo["trackId"].toString(), position);
}
void AudioPlayer::mpPlaybackCompleted() {
    this->next();
}

void AudioPlayer::npPlay() {
    this->play();
}
void AudioPlayer::npPause() {
    this->pause();
}
void AudioPlayer::npRevoked() {
    this->stop();
}
void AudioPlayer::npPrevious() {
    this->previous();
}
void AudioPlayer::npNext() {
    this->next();
}

QVariant AudioPlayer::albumInfo() const {
    return this->mAlbumInfo;
}
QVariant AudioPlayer::albumDetail() const {
    return this->mAlbumDetail;
}

void AudioPlayer::setAlbumInfo(const QVariant albumInfo) {
    this->mAlbumInfo = albumInfo;
    emit albumInfoChanged();
}

void AudioPlayer::setAlbumDetail(const QVariant albumDetail) {
    this->mAlbumDetail = albumDetail;
}

// 根据声音ID，获取信息
QMap<QString, QVariant> AudioPlayer::getTrackItemNyId(QString trackId) {
    QMap<QString, QVariant> rt;
    QMap<QString, QVariant> item;
    // 获取地址
    QMap<QString, QVariant> info = this->mAlbumInfo.toMap();
    QMap<QString, QVariant> data = info["data"].toMap();
    QList<QVariant> list = data["list"].toList();

    int i = 0;
    for(i = 0; i < list.length(); i++) {
        item = list.at(i).toMap();
        if(item["trackId"].toString() == trackId) {
            rt = item;
            break;
        }
    }

    return rt;
}

// 获取下一曲的信息，如果没有下一曲，则返回空
QMap<QString, QVariant> AudioPlayer::getPreNextTrackItem(int flag) {
    QMap<QString, QVariant> rt;
    QMap<QString, QVariant> item;

    QMap<QString, QVariant> info = this->mAlbumInfo.toMap();
    QMap<QString, QVariant> data = info["data"].toMap();
    QList<QVariant> list = data["list"].toList();

    bool isSearched = false;
    int i = 0, nextIndex, preIndex;

    for(i = 0; i < list.length(); i++) {
        item = list.at(i).toMap();
        if(item["trackId"].toString() == this->currentTrackInfo["trackId"].toString()) {
            nextIndex = i + 1;
            preIndex = i - 1;
            isSearched = true;
            break;
        }
    }

    if(isSearched) {
        if(flag == 1 && nextIndex < list.length()) {
            rt = list.at(nextIndex).toMap();
        }
        if(flag == -1 && preIndex >= 0) {
            rt = list.at(preIndex).toMap();
        }
    }

    return rt;
}

// 获取上一页专辑信息
void AudioPlayer::playPreAlbum() {
    QMap<QString, QVariant> info = this->mAlbumInfo.toMap();
    QMap<QString, QVariant> data = info["data"].toMap();
    QList<QVariant> list = data["list"].toList();
    int currentPage = data["pageId"].toInt();

    if(currentPage - 1 > 0) {
        QString albumId = list.at(0).toMap()["albumId"].toString();
        QString isAsc = Misc::getConfig("isAsc::albumId::" + albumId, "1") == "1" ? "true" : "false"; // 排序，缓存中取。
        QString url = AudioPlayer::albumInfoApi.arg(albumId).arg(currentPage - 1).arg(isAsc);

        requester = new Requester();
        requester->send(url);
        connect(requester, SIGNAL(finished(QString)), this, SLOT(getPreAlbumFinished(QString)));
        connect(requester, SIGNAL(error(QString)), this, SLOT(getPreAlbumError(QString)));
    }else {
        emit albumEnd(-1);
    }
}
void AudioPlayer::getPreAlbumFinished(QString data) {
    JsonDataAccess jda;
    QVariant albumInfo = jda.loadFromBuffer(data.toUtf8());

    QMap<QString, QVariant> info = albumInfo.toMap();
    QMap<QString, QVariant> dataMap = info["data"].toMap();
    QList<QVariant> list = dataMap["list"].toList();
    int lastIndex = list.size() - 1;

    // 判断上一页最后一个使用是不是付费
    QMap<QString, QVariant> itemInfo = list.at(lastIndex).toMap();

    if(itemInfo["isPaid"].toBool() && !itemInfo["isFree"].toBool()) {
        qDebug() << "AudioPlayer::getPreAlbumFinished isFree" << itemInfo["isFree"].toBool();
        emit track404();
        return;
    }

    this->setAlbumInfo(albumInfo);
    // 播放最后一首
    this->go(list.at(lastIndex).toMap());
}
void AudioPlayer::getPreAlbumError(QString errorMsg) {
    qDebug() << "AudioPlayer::getPreAlbumError errorMsg:" << errorMsg;
}

// 获取下一页专辑信息
void AudioPlayer::playNextAlbum() {
    QMap<QString, QVariant> info = this->mAlbumInfo.toMap();
    QMap<QString, QVariant> data = info["data"].toMap();
    QList<QVariant> list = data["list"].toList();
    int currentPage = data["pageId"].toInt();

    if(currentPage < data["maxPageId"].toInt()) {
        QString albumId = list.at(0).toMap()["albumId"].toString();
        QString isAsc = Misc::getConfig("isAsc::albumId::" + albumId, "1") == "1" ? "true" : "false"; // 排序，缓存中取。
        QString url = AudioPlayer::albumInfoApi.arg(albumId).arg(currentPage + 1).arg(isAsc);

        requester = new Requester();
        requester->send(url);
        connect(requester, SIGNAL(finished(QString)), this, SLOT(getNextAlbumFinished(QString)));
        connect(requester, SIGNAL(error(QString)), this, SLOT(getNextAlbumError(QString)));
    }else {
        emit albumEnd(1);
    }
}
void AudioPlayer::getNextAlbumFinished(QString data) {
    JsonDataAccess jda;
    QVariant albumInfo = jda.loadFromBuffer(data.toUtf8());

    QMap<QString, QVariant> info = albumInfo.toMap();
    QMap<QString, QVariant> dataMap = info["data"].toMap();
    QList<QVariant> list = dataMap["list"].toList();

    // 判断下一页是不是付费声音
    QMap<QString, QVariant> itemInfo = list.at(0).toMap();

    if(itemInfo["isPaid"].toBool() && !itemInfo["isFree"].toBool()) {
        qDebug() << "AudioPlayer::getNextAlbumFinished isFree" << itemInfo["isFree"].toBool();
        emit track404();
        return;
    }

    this->setAlbumInfo(albumInfo);
    // 播放第一首
    this->go(list.at(0).toMap());
}
void AudioPlayer::getNextAlbumError(QString errorMsg) {
    qDebug() << "AudioPlayer::getNextAlbumError errorMsg:" << errorMsg;
}

// 设置 metaData 和 icon
void AudioPlayer::setNpInfo(QMap<QString, QVariant> trackItem) {
    QVariantMap metaData;

    metaData.insert("artist", trackItem["nickname"].toString());
    metaData.insert("title", trackItem["title"].toString());

    nowPlayingConnection->setMetaData(metaData);
    nowPlayingConnection->setIconUrl(QUrl("asset:///images/ting_np_icon.png"));
}

// 当前播放声音的信息
QVariant AudioPlayer::getCurrentTrackInfo() {
    return this->currentTrackInfo;
}

// 播放声音
void AudioPlayer::go(QString trackId) {
    this->go(this->getTrackItemNyId(trackId));
}
void AudioPlayer::go(QMap<QString, QVariant> trackItem) {
    if(!trackItem.isEmpty()) {
        /**
         * 播放源和大小
         * playUrl64 e.g. 5.26mb
         * playUrl32 e.g. 2.63mb
         * playPathAacv224 e.g. 2.04mb
         * playPathAacv164 e.g. 5.33mb
         *
         * playPathHq 高质量，有的没有  // 默认
         */
        QString audioPlayerSourceType = Misc::getConfig("audioPlayerSourceType", "playPathHq");
        QString playUrl;

        if(audioPlayerSourceType == "playPathHq" && trackItem["playPathHq"].toString() == "") { // 如果没有高质量声音，那就设置为 playUrl64
            audioPlayerSourceType = "playUrl64";
        }

        playUrl = trackItem[audioPlayerSourceType].toString();

        qDebug() << "AudioPlayer::go source type:" << audioPlayerSourceType << ", play url:" << playUrl;

        if(trackItem["isPaid"].toBool() && !trackItem["isFree"].toBool()) { // 付费声音
            qDebug() << "AudioPlayer::go isFree" << trackItem["isFree"].toBool();
            emit track404();
            return;
        }

        this->setSourceUrl(playUrl);
        this->setNpInfo(trackItem);
        this->startPlayTimer();

        // 保存当前信息
        this->currentTrackInfo = trackItem;
        // 保存标志到 Settings 中
        Misc::setConfig("currentPlayTrackId", trackItem["trackId"].toString());

        /**
         * 保存播放历史记录，最多保存近100条
         */
        this->savePlayLog(trackItem["trackId"].toString(), trackItem, this->mAlbumInfo, this->mAlbumDetail, 0);

        // 返回信息，用于更新界面
        emit currentTrackChanged(trackItem["trackId"].toString());
    }else {
        qDebug() << "AudioPlayer::go trackItem isEmpty";
        emit track404();
    }
}

// 下一个
void AudioPlayer::next() {
    // 获取当前播放的信息
    QMap<QString, QVariant> trackItem = this->getPreNextTrackItem(1);
    if(trackItem.isEmpty()) {
        // 没有下一曲了，加载下一页的内容
        this->playNextAlbum();
    }else {
        emit preNextTrack(1);

        this->go(trackItem);
    }
}

// 上一个
void AudioPlayer::previous() {
    // 获取当前播放的信息
    QMap<QString, QVariant> trackItem = this->getPreNextTrackItem(-1);
    if(trackItem.isEmpty()) {
        // 没有去一曲了，加载上一页的内容
        this->playPreAlbum();

    }else {
        emit preNextTrack(-1);

        this->go(trackItem);
    }
}

void AudioPlayer::startPlayTimer() {
    this->playTimer->stop();
    this->playTimer->setInterval(300);
    this->playTimer->start();

    qDebug() << "AudioPlayer::startPlayTimer execute this->playTimer->start() ~~~~~";
}
void AudioPlayer::playTimerTimeout() {
    this->playTimer->stop();
    this->setVolume(1);
    this->play();
}

void AudioPlayer::startExitTimer(int m) {
    if(m == -1) {
        this->exitTimer->stop();
        emit exitTimerInterval(0, 0);
        return;
    }

    this->exitTime = m * 1000 * 60;
    this->currentExitTime = 0;

    this->exitTimer->stop();
    this->exitTimer->setInterval(1000);
    this->exitTimer->start();

    emit exitTimerInterval(this->currentExitTime, this->exitTime);
}
void AudioPlayer::exitTimerTimeout() {
    this->currentExitTime = this->currentExitTime + 1000;

    if(this->currentExitTime >= this->exitTime) {
        this->exitTimer->stop();
        emit exitTimerInterval(0, 0);
        // 关闭应用
        Misc::exit();
    }else {
        emit exitTimerInterval(this->currentExitTime, this->exitTime);
    }
}

// 更新播放历史记录播放进度
void AudioPlayer::updatePlayLogPosition(QString trackId, unsigned int position) {
    int nowTime = QDateTime::currentDateTime().toTime_t();

    // 5s保存一次
    if(nowTime - this->lastSavePositionTime < 5) {
        return;
    }

    this->lastSavePositionTime = nowTime;

    JsonDataAccess jda;
    QVariant playLog = jda.loadFromBuffer(Misc::getConfig("playLog", "[]").toUtf8());
    QList<QVariant> playLogList = playLog.toList();

    int i = 0;
    QMap<QString, QVariant> item;

    for(i = 0; i < playLogList.length(); i++) {
        item = playLogList.at(i).toMap();
        if(item["trackId"] == trackId) {
            item["position"] = QString::number(position);
            playLogList.replace(i, item);
            break;
        }
    }

    QString jsonString;
    jda.saveToBuffer(playLogList, &jsonString);

    Misc::setConfig("playLog", jsonString);
}

void AudioPlayer::deletePlayLogByAlbumId(QVariant albumId) {
    JsonDataAccess jda;
    QVariant playLog = jda.loadFromBuffer(Misc::getConfig("playLog", "[]").toUtf8());
    QList<QVariant> playLogList = playLog.toList();

    int i = 0;
    QMap<QString, QVariant> item;

    for(i = 0; i < playLogList.length(); i++) {
        item = playLogList.at(i).toMap();
        if(item["albumId"] == albumId) {
            playLogList.removeAt(i);
            break;
        }
    }

    QString jsonString;
    jda.saveToBuffer(playLogList, &jsonString);

    Misc::setConfig("playLog", jsonString);
}

void AudioPlayer::savePlayLog(QString trackId,
        QMap<QString, QVariant> trackInfo,
        QVariant albumInfo,
        QVariant mAlbumDetail,
        unsigned int position) {

    QVariant albumId = mAlbumDetail.toMap()["albumId"];

    QVariantMap map;
    map.insert("trackId", trackId); // 声音id
    map.insert("trackInfo", trackInfo); // 声音信息
    map.insert("albumId", albumId); // 专辑ID
    map.insert("mAlbumDetail", mAlbumDetail); // 当前播放专辑详细信息
    map.insert("albumInfo", albumInfo); // 当前播放列表信息
    map.insert("position", QString::number(position)); // 当前播放的位置

    JsonDataAccess jda;
    QVariant playLog = jda.loadFromBuffer(Misc::getConfig("playLog", "[]").toUtf8());

    QList<QVariant> playLogList = playLog.toList();

    // 如果存在相同专辑，则删除
    int i = 0;
    QMap<QString, QVariant> item;

    for(i = 0; i < playLogList.length(); i++) {
        item = playLogList.at(i).toMap();
        if(item["albumId"] == albumId) {
            playLogList.removeAt(i);
            break;
        }
    }

    // 最新播放的放入最前面
    playLogList.prepend(map);

    // 最多10条
    if(playLogList.length() > AudioPlayer::maxPlayLogSize) {
        playLogList.removeLast();
    }

    QString jsonString;
    jda.saveToBuffer(playLogList, &jsonString);

    Misc::setConfig("playLog", jsonString);
}
