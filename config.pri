# Config.pri file version 2.0. Auto-generated by IDE. Any changes made by user will be lost!
BASEDIR = $$quote($$_PRO_FILE_PWD_)

device {
    CONFIG(debug, debug|release) {
        profile {
            CONFIG += \
                config_pri_assets \
                config_pri_source_group1
        } else {
            CONFIG += \
                config_pri_assets \
                config_pri_source_group1
        }

    }

    CONFIG(release, debug|release) {
        !profile {
            CONFIG += \
                config_pri_assets \
                config_pri_source_group1
        }
    }
}

simulator {
    CONFIG(debug, debug|release) {
        !profile {
            CONFIG += \
                config_pri_assets \
                config_pri_source_group1
        }
    }
}

config_pri_assets {
    OTHER_FILES += \
        $$quote($$BASEDIR/assets/api.js) \
        $$quote($$BASEDIR/assets/common/Common.qml) \
        $$quote($$BASEDIR/assets/components/Line.qml) \
        $$quote($$BASEDIR/assets/components/RefreshHeader.qml) \
        $$quote($$BASEDIR/assets/images/album_cover_bg.png) \
        $$quote($$BASEDIR/assets/images/album_tracks_icon.png) \
        $$quote($$BASEDIR/assets/images/app/logo_110x110.png) \
        $$quote($$BASEDIR/assets/images/app/logo_144x144.png) \
        $$quote($$BASEDIR/assets/images/app/logo_86x86.png) \
        $$quote($$BASEDIR/assets/images/app/logo_90x90.png) \
        $$quote($$BASEDIR/assets/images/app/logo_96x96.png) \
        $$quote($$BASEDIR/assets/images/app/welcome_1024x600.png) \
        $$quote($$BASEDIR/assets/images/app/welcome_1440x1440.png) \
        $$quote($$BASEDIR/assets/images/app/welcome_720x1280.png) \
        $$quote($$BASEDIR/assets/images/app/welcome_720x720.png) \
        $$quote($$BASEDIR/assets/images/app/welcome_768x1280.png) \
        $$quote($$BASEDIR/assets/images/audio_player/aco.png) \
        $$quote($$BASEDIR/assets/images/audio_player/add.png) \
        $$quote($$BASEDIR/assets/images/audio_player/af.png) \
        $$quote($$BASEDIR/assets/images/audio_player/loading.png) \
        $$quote($$BASEDIR/assets/images/avatars_icon.png) \
        $$quote($$BASEDIR/assets/images/bb10/ic_contact.png) \
        $$quote($$BASEDIR/assets/images/bb10/ic_edit_bookmarks.png) \
        $$quote($$BASEDIR/assets/images/bb10/ic_forward.png) \
        $$quote($$BASEDIR/assets/images/bb10/ic_home.png) \
        $$quote($$BASEDIR/assets/images/bb10/ic_info.png) \
        $$quote($$BASEDIR/assets/images/bb10/ic_pause.png) \
        $$quote($$BASEDIR/assets/images/bb10/ic_play.png) \
        $$quote($$BASEDIR/assets/images/bb10/ic_reply.png) \
        $$quote($$BASEDIR/assets/images/bb10/ic_search.png) \
        $$quote($$BASEDIR/assets/images/bb10/ic_show_vkb.png) \
        $$quote($$BASEDIR/assets/images/no_content.png) \
        $$quote($$BASEDIR/assets/images/pay_icon.png) \
        $$quote($$BASEDIR/assets/images/play_in_track_item.png) \
        $$quote($$BASEDIR/assets/images/sound_comments_icon.png) \
        $$quote($$BASEDIR/assets/images/sound_duration_icon.png) \
        $$quote($$BASEDIR/assets/images/sound_playtimes_icon.png) \
        $$quote($$BASEDIR/assets/images/ting_default.png) \
        $$quote($$BASEDIR/assets/images/ting_np_icon.png) \
        $$quote($$BASEDIR/assets/images/user_grade/individual_orangeV0.png) \
        $$quote($$BASEDIR/assets/images/user_grade/individual_orangeV1.png) \
        $$quote($$BASEDIR/assets/images/user_grade/individual_orangeV10.png) \
        $$quote($$BASEDIR/assets/images/user_grade/individual_orangeV11.png) \
        $$quote($$BASEDIR/assets/images/user_grade/individual_orangeV12.png) \
        $$quote($$BASEDIR/assets/images/user_grade/individual_orangeV13.png) \
        $$quote($$BASEDIR/assets/images/user_grade/individual_orangeV14.png) \
        $$quote($$BASEDIR/assets/images/user_grade/individual_orangeV15.png) \
        $$quote($$BASEDIR/assets/images/user_grade/individual_orangeV16.png) \
        $$quote($$BASEDIR/assets/images/user_grade/individual_orangeV2.png) \
        $$quote($$BASEDIR/assets/images/user_grade/individual_orangeV3.png) \
        $$quote($$BASEDIR/assets/images/user_grade/individual_orangeV4.png) \
        $$quote($$BASEDIR/assets/images/user_grade/individual_orangeV5.png) \
        $$quote($$BASEDIR/assets/images/user_grade/individual_orangeV6.png) \
        $$quote($$BASEDIR/assets/images/user_grade/individual_orangeV7.png) \
        $$quote($$BASEDIR/assets/images/user_grade/individual_orangeV8.png) \
        $$quote($$BASEDIR/assets/images/user_grade/individual_orangeV9.png) \
        $$quote($$BASEDIR/assets/main.qml) \
        $$quote($$BASEDIR/assets/main_bak.qml) \
        $$quote($$BASEDIR/assets/pages/album.qml) \
        $$quote($$BASEDIR/assets/pages/audioPlayerUI.qml) \
        $$quote($$BASEDIR/assets/pages/child/AlbumItem.qml) \
        $$quote($$BASEDIR/assets/pages/child/ItemContainer.qml) \
        $$quote($$BASEDIR/assets/pages/child/TrackItem.qml) \
        $$quote($$BASEDIR/assets/pages/child/UserItem.qml) \
        $$quote($$BASEDIR/assets/pages/index.qml) \
        $$quote($$BASEDIR/assets/pages/search.qml)
}

config_pri_source_group1 {
    SOURCES += \
        $$quote($$BASEDIR/src/AudioPlayer/AudioPlayer.cpp) \
        $$quote($$BASEDIR/src/Misc/Misc.cpp) \
        $$quote($$BASEDIR/src/Requester/Requester.cpp) \
        $$quote($$BASEDIR/src/WebImageView/WebImageView.cpp) \
        $$quote($$BASEDIR/src/applicationui.cpp) \
        $$quote($$BASEDIR/src/main.cpp)

    HEADERS += \
        $$quote($$BASEDIR/src/AudioPlayer/AudioPlayer.hpp) \
        $$quote($$BASEDIR/src/Misc/Misc.hpp) \
        $$quote($$BASEDIR/src/Requester/Requester.hpp) \
        $$quote($$BASEDIR/src/WebImageView/WebImageView.hpp) \
        $$quote($$BASEDIR/src/applicationui.hpp)
}

CONFIG += precompile_header

PRECOMPILED_HEADER = $$quote($$BASEDIR/precompiled.h)

lupdate_inclusion {
    SOURCES += \
        $$quote($$BASEDIR/../src/*.c) \
        $$quote($$BASEDIR/../src/*.c++) \
        $$quote($$BASEDIR/../src/*.cc) \
        $$quote($$BASEDIR/../src/*.cpp) \
        $$quote($$BASEDIR/../src/*.cxx) \
        $$quote($$BASEDIR/../src/AudioPlayer/*.c) \
        $$quote($$BASEDIR/../src/AudioPlayer/*.c++) \
        $$quote($$BASEDIR/../src/AudioPlayer/*.cc) \
        $$quote($$BASEDIR/../src/AudioPlayer/*.cpp) \
        $$quote($$BASEDIR/../src/AudioPlayer/*.cxx) \
        $$quote($$BASEDIR/../src/Misc/*.c) \
        $$quote($$BASEDIR/../src/Misc/*.c++) \
        $$quote($$BASEDIR/../src/Misc/*.cc) \
        $$quote($$BASEDIR/../src/Misc/*.cpp) \
        $$quote($$BASEDIR/../src/Misc/*.cxx) \
        $$quote($$BASEDIR/../src/Requester/*.c) \
        $$quote($$BASEDIR/../src/Requester/*.c++) \
        $$quote($$BASEDIR/../src/Requester/*.cc) \
        $$quote($$BASEDIR/../src/Requester/*.cpp) \
        $$quote($$BASEDIR/../src/Requester/*.cxx) \
        $$quote($$BASEDIR/../src/WebImageView/*.c) \
        $$quote($$BASEDIR/../src/WebImageView/*.c++) \
        $$quote($$BASEDIR/../src/WebImageView/*.cc) \
        $$quote($$BASEDIR/../src/WebImageView/*.cpp) \
        $$quote($$BASEDIR/../src/WebImageView/*.cxx) \
        $$quote($$BASEDIR/../assets/*.qml) \
        $$quote($$BASEDIR/../assets/*.js) \
        $$quote($$BASEDIR/../assets/*.qs) \
        $$quote($$BASEDIR/../assets/common/*.qml) \
        $$quote($$BASEDIR/../assets/common/*.js) \
        $$quote($$BASEDIR/../assets/common/*.qs) \
        $$quote($$BASEDIR/../assets/components/*.qml) \
        $$quote($$BASEDIR/../assets/components/*.js) \
        $$quote($$BASEDIR/../assets/components/*.qs) \
        $$quote($$BASEDIR/../assets/images/*.qml) \
        $$quote($$BASEDIR/../assets/images/*.js) \
        $$quote($$BASEDIR/../assets/images/*.qs) \
        $$quote($$BASEDIR/../assets/images/app/*.qml) \
        $$quote($$BASEDIR/../assets/images/app/*.js) \
        $$quote($$BASEDIR/../assets/images/app/*.qs) \
        $$quote($$BASEDIR/../assets/images/audio_player/*.qml) \
        $$quote($$BASEDIR/../assets/images/audio_player/*.js) \
        $$quote($$BASEDIR/../assets/images/audio_player/*.qs) \
        $$quote($$BASEDIR/../assets/images/bb10/*.qml) \
        $$quote($$BASEDIR/../assets/images/bb10/*.js) \
        $$quote($$BASEDIR/../assets/images/bb10/*.qs) \
        $$quote($$BASEDIR/../assets/images/user_grade/*.qml) \
        $$quote($$BASEDIR/../assets/images/user_grade/*.js) \
        $$quote($$BASEDIR/../assets/images/user_grade/*.qs) \
        $$quote($$BASEDIR/../assets/pages/*.qml) \
        $$quote($$BASEDIR/../assets/pages/*.js) \
        $$quote($$BASEDIR/../assets/pages/*.qs) \
        $$quote($$BASEDIR/../assets/pages/child/*.qml) \
        $$quote($$BASEDIR/../assets/pages/child/*.js) \
        $$quote($$BASEDIR/../assets/pages/child/*.qs)

    HEADERS += \
        $$quote($$BASEDIR/../src/*.h) \
        $$quote($$BASEDIR/../src/*.h++) \
        $$quote($$BASEDIR/../src/*.hh) \
        $$quote($$BASEDIR/../src/*.hpp) \
        $$quote($$BASEDIR/../src/*.hxx)
}

TRANSLATIONS = $$quote($${TARGET}.ts)
