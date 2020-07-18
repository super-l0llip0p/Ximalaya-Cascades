import bb.cascades 1.4
import bb.multimedia 1.4
import tech.lwl 1.0
import "asset:///common"
import "asset:///pages" as Page

TabbedPane {
    id: tabbedPane
    property variant nav: activeTab.tabNav // 所以页面可用导航
    property bool backButtonVisiable: _misc.getConfig(common.settingsKey.backButtonVisiable, "1") === "1" // 是否显示返回按钮
    // audioPlayerUI property start
    property variant audioPlayerUIPage // 播放器页面
    property variant albumInfo // 专辑信息
    property variant trackId // 声音ID
    // audioPlayerUI property end
    property variant lastViewCategory: _misc.getConfig(common.settingsKey.lastViewCategory, "[]")
    
    showTabsOnActionBar: false
    activeTab: indexTab // 默认 activeTab 为 主页
    // activeTab: searchTab // 默认 activeTab 为 主页
    
    shortcuts: [
        Shortcut {
            key: common.shortCutKey.openPlayer
            onTriggered: {
                if(nav.top.objectName !== "audioPlayer") {
                    pushAudioPlayerUI(-1);
                }
            }
        },
        Shortcut {
            key: common.shortCutKey.back
            onTriggered: {
                if(nav.count() !== 1) {
                    nav.pop();
                }
            }
        },
        Shortcut {
            key: common.shortCutKey.indexPage
            onTriggered: {
                if(nav.count() === 1) {
                    activeTab = indexTab;
                }
            }
        },
        Shortcut {
            key: common.shortCutKey.searhPage
            onTriggered: {
                if(nav.count() === 1) {
                    activeTab = searchTab;
                }
            }
        }
    ]
    
    Menu.definition: MenuDefinition {
        helpAction: HelpActionItem {
            title: qsTr("帮助")
            onTriggered: {
                nav.push(helpPage.createObject());
            }
        }
        settingsAction: SettingsActionItem {
            title: qsTr("设置")
            onTriggered: {
                nav.push(settingsPage.createObject());
            }
        }
        actions: [
            ActionItem {
                title: qsTr("赞助")
                imageSource: "asset:///images/bb10/ic_contact.png"
                onTriggered: {
                    nav.push(sponsorInfoPage.createObject());
                }
            },
            ActionItem {
                title: qsTr("关于作者")
                imageSource: "asset:///images/bb10/ic_edit_bookmarks.png"
                onTriggered: {
                    _misc.invokeBrowser(common.authorWebSite);
                }
            },
            ActionItem {
                title: qsTr("关于")
                imageSource: "asset:///images/bb10/ic_info.png"
                onTriggered: {
                    nav.push(aboutPage.createObject());
                }
            }
        ]
    }
    
    tabs: [
        Tab {
            id: indexTab
            property alias tabNav: indexNav
            title: qsTr("主页")
            imageSource: "asset:///images/bb10/ic_home.png"
            NavigationPane {
                id: indexNav
                Page.index {}
                onPopTransitionEnded: common.onPopTransitionEnded(nav, page)
                onPushTransitionEnded: common.onPushTransitionEnded(nav, page)
                backButtonsVisible: tabbedPane.backButtonVisiable
            }
        },
        Tab {
            id: searchTab
            property alias tabNav: searchNav
            title: qsTr("搜索")
            imageSource: "asset:///images/bb10/ic_search.png"
            NavigationPane {
                id: searchNav
                Page.search {}
                onPopTransitionEnded: common.onPopTransitionEnded(nav, page)
                onPushTransitionEnded: common.onPushTransitionEnded(nav, page)
                backButtonsVisible: tabbedPane.backButtonVisiable
            }
        }
    ]
    
    attachedObjects: [
        ComponentDefinition {
            id: helpPage
            source: "asset:///pages/help.qml"
        },
        AudioPlayer {
            id: player
            onPositionChanged: {
                audioPlayerUIPage && audioPlayerUIPage.positionChanged(position)
            }
            onDurationChanged: {
                audioPlayerUIPage && audioPlayerUIPage.durationChanged(duration);
            }
            onMediaStateChanged: {
                audioPlayerUIPage && audioPlayerUIPage.mediaStateChanged(mediaState);
            }
            onCurrentTrackChanged: {
                audioPlayerUIPage && audioPlayerUIPage.currentTrackChanged(trackId);
            }
            onAlbumInfoChanged: {
                audioPlayerUIPage && audioPlayerUIPage.albumInfoChanged();
            }
            onAlbumEnd: {
                audioPlayerUIPage && audioPlayerUIPage.albumEnd(flag);
            }
            onTrack404: {
                audioPlayerUIPage && audioPlayerUIPage.track404();
            }
            onPreNextTrack: {
                audioPlayerUIPage && audioPlayerUIPage.preNextTrack();
            }
            onExitTimerInterval: {
                audioPlayerUIPage && audioPlayerUIPage.exitTimerInterval(currentExitTime, exitTime);
            }
        },
        ComponentDefinition {
            id: audioPlayerUI
            source: "asset:///pages/audioPlayerUI.qml"
        },
        QTimer {
            id: audioPlayerUItimer
            interval: 200
            onTimeout: {
                audioPlayerUItimer.stop();
                tabbedPane.initAudioPlayerUIParams();
            }
        },
        QTimer {
            id: messageTimer
            interval: 2000
            onTimeout: {
                messageTimer.stop();
                common.apiMessage(messageRequester);
            }
        },
        Requester {
            id: messageRequester
            onFinished: {
                messageTimer.stop();
                
                var rs = JSON.parse(data);
                var info = rs.info;
                var isFirstShow = _misc.getConfig(common.settingsKey.developerMessageVersion, "0") != info['version'];
                
                if(rs.code === 200 && (isFirstShow || info['always'])) {
                    // 弹出消息
                    common.openDialog(info['title'], info['body'] + '' + info['date']);
                    // 存储最新的消息版本，只提示一次
                    _misc.setConfig(common.settingsKey.developerMessageVersion, info['version']);
                }
            }
        },
        Common {
            id: common
        },
        ComponentDefinition {
            id: aboutPage
            source: "asset:///pages/about.qml"
        },
        ComponentDefinition {
            id: settingsPage
            source: "asset:///pages/settings.qml"
        },
        ComponentDefinition {
            id: sponsorInfoPage
            source: "asset:///pages/sponsorInfo.qml"
        }
    ]
    
    onCreationCompleted: {
        // 设置主题
        _misc.setTheme(_misc.getConfig(common.settingsKey.theme, "Bright"));
        // 默认播放最高质量的声音
        _misc.setConfig(common.settingsKey.audioPlayerSourceType, "playPathHq");
        // 读取消息
        messageTimer.start();
    }
    
    /**
     * 进入播放器
     * 如果是直接进入，trackId = -1
     */
    function pushAudioPlayerUI(trackId, albumInfo) {
        audioPlayerUIPage = audioPlayerUI.createObject();
        nav.push(audioPlayerUIPage);
        // 保存至 tabbedPane 中，提供给 timer 使用
        tabbedPane.trackId = trackId;
        tabbedPane.albumInfo = albumInfo;
        
        audioPlayerUItimer.start();
    }
    function initAudioPlayerUIParams() {
        audioPlayerUIPage.audioPlayer = player;
        audioPlayerUIPage.albumInfo = tabbedPane.albumInfo;
        audioPlayerUIPage.trackId = tabbedPane.trackId; // 注意顺序，trackId 赋值必须在最后面。
    }
}
