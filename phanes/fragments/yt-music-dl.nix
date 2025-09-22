{ config, lib, pkgs, ... }:
with lib;
let
  playlists = {
    "wubwubwub" = "https://www.youtube.com/playlist?list=PLjgVd_07uAd95EmLlzcafgYjwIqHnIDUg";
    "cool stuff" = "https://www.youtube.com/playlist?list=PLjgVd_07uAd9LSrikWrxkUKQs9NmVKx69";
    "weeb shit" = "https://www.youtube.com/playlist?list=PLjgVd_07uAd-JL2Wz1Zr9q7aVKG8pBdZA";
  };
  channels = {
    "Absurdismworld" = "https://www.youtube.com/c/Absurdismworldsarchivechannel/videos";
    "AirwaveMusicTV" = "https://www.youtube.com/c/AirwaveMusicTV/videos";
    "Astrophysics" = "https://www.youtube.com/c/Astrophysicsynth/videos";
    "Au5" = "https://www.youtube.com/channel/UCznSBwEKa4xU8HmbEXCv6Yw/videos";
    "Black Out Records" = "https://www.youtube.com/channel/UCTR8VxIcQOix5Fj55KRu2Qg/videos";
    "BlackmillMusic" = "https://www.youtube.com/channel/UCH1-EnWEmTSECo-gDIweFDA/videos";
    "Blackout Music" = "https://www.youtube.com/channel/UCXLGu6onmiH8ZA_i-dIO5Lg/videos";
    "Camellia" = "https://www.youtube.com/channel/UCV4ggxLd_Vz-I-ePGSKfFog/videos";
    "Cider Party" = "https://www.youtube.com/c/CiderParty/videos";
    "Circus Records" = "https://www.youtube.com/c/circusrecords/videos";
    "Distraction" = "https://www.youtube.com/@Distractionedm/videos";
    "DjEphixa" = "https://www.youtube.com/channel/UCGfBXs27YPr0U8CFim-RefQ/videos";
    "DJT" = "https://www.youtube.com/channel/UC09L_fOVn3Tg0NKNJl9njCA/videos";
    "Dubstep uNk" = "https://www.youtube.com/c/DubstepuNkOfficial/videos";
    "DubstepGutter" = "https://www.youtube.com/channel/UCG6QEHCBfWZOnv7UVxappyw/videos";
    "Far Too Loud" = "https://www.youtube.com/channel/UCRpyx8avnqPAaAbLIWDFlpw/videos";
    "Fox Stevenson" = "https://www.youtube.com/channel/UClAxKFEVmERwGhcUhpCzlWw/videos";
    "Hay Tea" = "https://www.youtube.com/c/HayFlavouredTea/videos";
    "HiTech Trance" = "https://www.youtube.com/c/hitechtrance/videos";
    "iblank2apples" = "https://www.youtube.com/c/iblank2apples/videos";
    "INF1N1TE" = "https://www.youtube.com/channel/UC9ivTxVsmSPFvQzUPMb9JgA/videos";
    "Inspector Dubplate" = "https://www.youtube.com/@InspectorDubplate/videos";
    "K-391" = "https://www.youtube.com/channel/UC1XoTfl_ctHKoEbe64yUC_g/videos";
    "luggi spikes" = "https://www.youtube.com/channel/UC5_I30UR32Pr-274nkXHQ_g/videos";
    "Madeon" = "https://www.youtube.com/channel/UCqMDNf3Pn5L7pcNkuSEeO3w/videos";
    "MDK" = "https://www.youtube.com/c/MDKOfficialYT/videos";
    "MikuMusicNetwork" = "https://www.youtube.com/@MikuMusicNetwork/videos";
    "Monstercat" = "https://www.youtube.com/channel/UCJ6td3C9QlPO9O_J5dF4ZzA/videos";
    "MrMoMMusic" = "https://www.youtube.com/c/MrMoMMusic/videos";
    "MrSuicideSheep" = "https://www.youtube.com/channel/UC5nc_ZtjKW1htCVZVRxlQAQ/videos";
    "nanobii" = "https://www.youtube.com/channel/UCz3hLJ8YpJSippp8LHjpwjg/videos";
    "NeurofunkGrid" = "https://www.youtube.com/@NeurofunkGrid/videos";
    "NoCopyrightSounds" = "https://www.youtube.com/channel/UC_aEa8K-EOJ3D6gOs7HcyNg/videos";
    "NXS" = "https://www.youtube.com/channel/UCl4UOc8h1ZnO-inFPgAu7gw/videos";
    "Owata P" = "https://www.youtube.com/playlist?list=PLTHHOGhQjO3Lau2C605abjcHLV4L5n67x";
    "OWSLA" = "https://www.youtube.com/@owsla/videos";
    "OxiDaksi" = "https://www.youtube.com/c/OxiDaksi/videos";
    "Proximity" = "https://www.youtube.com/channel/UC3ifTl5zKiCAhHIBQYcaTeg/videos";
    "ReclusiveLemming" = "https://www.youtube.com/@ReclusiveLemming/videos";
    "Reinelex Music" = "https://www.youtube.com/c/Reinelex/videos";
    "roboctopus" = "https://www.youtube.com/channel/UCVNu8yd7tptY8d3EA_PHmkw/videos";
    "S3RL" = "https://www.youtube.com/channel/UCb6JTMjrHZCYFD9Y04CBk9g/videos";
    "Solar Heavy" = "https://www.youtube.com/c/SolarHeavy/videos";
    "StephenWalking" = "https://www.youtube.com/channel/UCiprAA9XNf1DjXJgNkck3yQ/videos";
    "Strobe Music" = "https://www.youtube.com/@TheStrobeMusic/videos";
    "SuicideSheeep" = "https://www.youtube.com/@SuicideSheeep/videos";
    "Syfer Music" = "https://www.youtube.com/c/SyferMusic/videos";
    "Synthion" = "https://www.youtube.com/@synthion/videos";
    "Tasty" = "https://www.youtube.com/channel/UC0n9yiP-AD2DpuuYCDwlNxQ/videos";
    "TCB" = "https://www.youtube.com/c/TCBpon/videos";
    "Technical Hitch" = "https://www.youtube.com/c/hitechsergio//videos";
    "The Dub Rebellion" = "https://www.youtube.com/channel/UCH3V-b6weBfTrDuyJgFioOw/videos";
    "Trap City" = "https://www.youtube.com/channel/UC65afEgL62PGFWXY7n6CUbA/videos";
    "Trap Nation" = "https://www.youtube.com/channel/UCa10nxShhzNrCE1o2ZOPztg/videos";
    "UKF DNB" = "https://www.youtube.com/c/UKFDrumandBass/videos";
    "UKF Dubstep" = "https://www.youtube.com/channel/UCfLFTP1uTuIizynWsZq2nkQ/videos";
    "UndreamedPanic" = "https://www.youtube.com/channel/UC5u0K5MNm_P5jmK3ByM0lpw/videos";
    "Wobblecraft" = "https://www.youtube.com/channel/UCqrxoI6XuLkVEY4S-oXibnA/videos";
    "xMerciAx" = "https://www.youtube.com/playlist?list=PLb1K-m5QT703CWP_Jhyblpwasjrgl_W81";
    "Yume" = "https://www.youtube.com/c/YumeNetwork/videos";
  };
  bandcampUsers = [
    "0101"
    "4banga"
    "633397"
    "aak3"
    "agonyost"
    "aikamusics"
    "anamanaguchi"
    "andrewhuang"
    "andypls"
    "angelvoidkin"
    "antennae"
    "astrophysicsbrazil"
    "atalea"
    "atariteenageriot"
    "au5music"
    "be4vtyfall"
    "besidesyou"
    "bkode"
    "blackballoonss"
    "blackoutrec"
    "blksmiith"
    "bye2"
    "chipzelmusic"
    "chisanahana"
    "clonepa"
    "clowncore"
    "cooldownreduction"
    "crashfaster"
    "cryptidcapra"
    "cvmpliant"
    "cynthoni"
    "dadaihaiji"
    "darkman007"
    "deathbrain"
    "dissolve3"
    "dokxid"
    "dracodracodracodraco"
    "dredcollective"
    "dubmood"
    "eightiesheadachetape"
    "emptybluemusic"
    "end-user"
    "erythh"
    "etherealhaven"
    "familyjules7x"
    "fantomenk"
    "freshtildesu"
    "gemtos"
    "geoxor"
    "glitchtrode"
    "gnbchili"
    "goreshit"
    "goreshitarchive"
    "gravitasrecordings"
    "gutterpink"
    "harmfullogic666"
    "heatace"
    "hkmori"
    "hxlyxo"
    "ibelieveinangels"
    "igorrr"
    "imkotori"
    "ivysinthetic"
    "iwakura1144"
    "iwannabeawitch"
    "ixfalls"
    "jacksonifyer"
    "jamiepaige"
    "jayakiba"
    "joy-less"
    "kaizoslumber"
    "kennyoung"
    "kentenshi"
    "knowermusic"
    "lainwired"
    "lapfox"
    "llwll"
    "lostfrog"
    "lukhash"
    "lxchee"
    "lydels"
    "m0-ney"
    "machinegirl"
    "madbreaks"
    "maladreezy"
    "maritumix"
    "masterbootrecord"
    "mayowithadot"
    "mayyro"
    "midbooze"
    "midxna"
    "mimideath"
    "mimosa"
    "mindvacy"
    "moeshop"
    "monstercatmedia"
    "myheadhurts"
    "nakedleisure"
    "nanode"
    "nanoray"
    "nasanoa"
    "nfract"
    "nitgrit"
    "noagreements"
    "noisechannel"
    "notnedaj"
    "nxcho"
    "opalfruits"
    "orqzeu"
    "paradoxically"
    "pisca"
    "plasmapool"
    "princewhateverer"
    "proloxx"
    "psykorecords"
    "pure-gem"
    "purityfilter"
    "quantumdigitsrecordings"
    "rampagerecordings"
    "resurrectionrecords"
    "rispaa"
    "rorynearly20s"
    "rosehiprose"
    "sageisdead"
    "serverofuser"
    "sfork"
    "sinksaiko"
    "skeinn"
    "softxoxos"
    "solarheavy"
    "sorryaboutmyface"
    "spurme"
    "staircatte"
    "strxwberrymilk"
    "stupiddecisions"
    "suigetsu"
    "synthion"
    "systemst91"
    "takahiro-fks"
    "tami-tomi"
    "theworstlabel"
    "tkdpll"
    "tokyopill"
    "tonroshi"
    "toomuchofme"
    "treyfrey"
    "turquoisedeath"
    "ukfmusic"
    "unclubbed"
    "undreamedpanic"
    "untitledexe"
    "usedcvnt"
    "vertigoaway"
    "vill4in"
    "virtualmemory777"
    "vixenvy"
    "voipetsu"
    "voodoo-hoodoo"
    "vrtlhvn"
    "yakuithemaid1"
    "yonkagor"
    "youngscrolls"
    "yumeko"
    "yungkkun"
    "yurisimaginarylabel"
    "zenkaso"
    "zhnoi"
  ];
  common-args = "-P 'temp:/sync/tmp/yt-music' --no-progress --no-post-overwrites --add-metadata";
  ytdlCookiesCredential = "yt-dl-cookies";
  tmpCookiesFile = "/tmp/cookies.txt";
  useYtCookiesCmd = "[ ! -f \"${tmpCookiesFile}\" ] && echo 'Cookies not found!' && exit 1";
  getYtDownloadCmd = { dir, url, archive ? dir, filter ? "" }: ''
    yt-dlp --cookies ${tmpCookiesFile} ${common-args} -o "${dir}/%(title)s-%(id)s.%(ext)s" --download-archive "${archive}.txt" \
    --extractor-args "youtube:player-client=default,tv,web_safari,web_embedded" \
    ${filter} \
    -ciwx -f bestaudio \
    --sleep-requests 0.5 --min-sleep-interval 10 --max-sleep-interval 15 \
    --add-metadata --replace-in-metadata 'album' '.' "" --parse-metadata 'title:%(track)s' --parse-metadata 'uploader:%(artist)s' "${url}"
  '';
  musicDir = "/sync/downloads/lossy-music";
  sanitiseServiceName = name: (builtins.replaceStrings [ " " ] [ "_" ] name);
  commonServiceConfig = {
    Type = "oneshot";
    User = "yt-music-dl";
    WorkingDirectory = "/home/yt-music-dl";
    UMask = "0000";
    TimeoutStartSec = "infinity";
  };
  dropinServiceOptions = {
    partOf = [ "music-dl.target" ];
    wantedBy = [ "music-dl.target" ];
    upholds = [ "music-dl-busy.target" ];
    path = [ "/home/yt-music-dl/.local" pkgs.ffmpeg ];
    overrideStrategy = "asDropin";
  };
  # yt-dlp exits with a non-zero code if errors like missing pages occur, but
  # also if there are private videos/pages without videos - and there is no
  # easy way to differentiate between these errors, so this must be manually toggled
  # to find out which pages should be removed from the download lists above.
  propagateErrors = false;
  getPostamble = sleepSecs: ''
    ${optionalString propagateErrors "EXIT_CODE=$?"}
    sleep ${sleepSecs}
    ${optionalString propagateErrors "exit $EXIT_CODE"}
  '';
in
{
  systemd = {
    timers.music-dl = {
      wantedBy = [ "timers.target" ];
      timerConfig = {
        OnCalendar = "daily";
        Persistent = true;
        Unit = "music-dl.target";
      };
    };

    targets = {
      music-dl = {
        after = [ "network.target" ];
        description = "Start music download services";
        unitConfig = {
          StopWhenUnneeded = "True";
        };
      };
      # TODO: maybe remove this because the target seems to be reached when all units
      # deactivate, which can also be used to determine the total service run time
      music-dl-busy = {
        description = "Active music download services";
        unitConfig = {
          StopWhenUnneeded = "True";
        };
      };
    };

    services = {
      music-dl-pre = {
        partOf = [ "music-dl.target" ];
        wantedBy = [ "music-dl.target" ];
        path = [ "/home/yt-music-dl/.local" ];
        serviceConfig = commonServiceConfig;

        script = ''
          ${pkgs.python311.pkgs.pip}/bin/pip install --break-system-packages --user --force-reinstall https://github.com/yt-dlp/yt-dlp/archive/master.tar.gz
          rm -f /home/yt-music-dl/*.lock
        '';
      };

      music-dl-load-yt-cookies = {
        partOf = [ "music-dl.target" ];
        wantedBy = [ "music-dl.target" ];
        unitConfig = {
          StopWhenUnneeded = "yes";
        };
        serviceConfig = commonServiceConfig // {
          PrivateTmp = "yes";
          LoadCredentialEncrypted = ytdlCookiesCredential;
          RemainAfterExit = "yes";
        };
        script = ''
          cat < $CREDENTIALS_DIRECTORY/${ytdlCookiesCredential} > ${tmpCookiesFile}
        '';
      };

      "music-dl-yt-playlist@" = {
        after = [ "music-dl-pre.service" "music-dl-load-yt-cookies.service" ];
        upholds = [ "music-dl-load-yt-cookies.service" ];
        path = [ "/home/yt-music-dl/.local" ];
        unitConfig = {
          JoinsNamespaceOf = "music-dl-load-yt-cookies.service";
        };
        serviceConfig = commonServiceConfig // (
          let
            script = pkgs.writeShellScript "music-dl-yt-playlist.sh" ''
              cd ${musicDir}/favourites
              ${useYtCookiesCmd}
              ${getYtDownloadCmd { dir = "$DIR"; url = "$URL"; }}
              ${getPostamble "60"}
            '';
          in
          {
            ExecStartPre = "${pkgs.procmail}/bin/lockfile -3 /home/yt-music-dl/dl-yt.lock";
            ExecStopPost = "${pkgs.coreutils}/bin/rm -f /home/yt-music-dl/dl-yt.lock";
            ExecStart = "${script} %i";
            PrivateTmp = "yes";
          }
        );
      };

      "music-dl-yt-channel@" = {
        after = [ "music-dl-pre.service" "music-dl-load-yt-cookies.service" ];
        upholds = [ "music-dl-load-yt-cookies.service" ];
        path = [ "/home/yt-music-dl/.local" ];
        unitConfig = {
          JoinsNamespaceOf = "music-dl-load-yt-cookies.service";
        };
        serviceConfig = commonServiceConfig // (
          let
            script = pkgs.writeShellScript "music-dl-yt-channel.sh" ''
              cd ${musicDir}/lossy-downloads/yt
              ${useYtCookiesCmd}
              ${getYtDownloadCmd { 
                dir = "%(upload_date)s/$DIR";
                archive = "$DIR";
                url = "$URL";
                filter = "--match-filter 'duration >= 90 & duration <= 660 & original_url!*=/shorts/'";
              }}
              ${getPostamble "60"}
            '';
          in
          {
            ExecStartPre = "${pkgs.procmail}/bin/lockfile -3 /home/yt-music-dl/dl-yt.lock";
            ExecStopPost = "${pkgs.coreutils}/bin/rm -f /home/yt-music-dl/dl-yt.lock";
            ExecStart = "${script} %i";
            PrivateTmp = "yes";
          }
        );
      };

      "music-dl-bandcamp@" = {
        after = [ "music-dl-pre.service" ];
        path = [ "/home/yt-music-dl/.local" ];
        serviceConfig = commonServiceConfig // (
          let
            script = pkgs.writeShellScript "music-dl-bandcamp.sh" ''
              cd ${musicDir}/lossy-downloads/bandcamp
              yt-dlp ${common-args} -ix -f 'flac/mp3' --download-archive "$1.txt" \
                -o "$1/%(album,track)s/%(playlist_index)s. %(title)s.%(ext)s" \
                "https://$1.bandcamp.com/music"
              ${getPostamble "60"}
            '';
          in
          {
            ExecStartPre = "${pkgs.procmail}/bin/lockfile -3 /home/yt-music-dl/dl-bc.lock";
            ExecStopPost = "${pkgs.coreutils}/bin/rm -f /home/yt-music-dl/dl-bc.lock";
            ExecStart = "${script} %i";
          }
        );
      };
    } // (
      mapAttrs'
        (name: url: nameValuePair "music-dl-yt-playlist@${sanitiseServiceName name}" (
          dropinServiceOptions // {
            environment = {
              DIR = name;
              URL = url;
            };
          }
        ))
        playlists
    ) // (
      mapAttrs'
        (name: url: nameValuePair "music-dl-yt-channel@${sanitiseServiceName name}" (
          dropinServiceOptions // {
            environment = {
              DIR = name;
              URL = url;
            };
          }
        ))
        channels
    ) // (
      listToAttrs (map
        (name: nameValuePair "music-dl-bandcamp@${name}" dropinServiceOptions)
        bandcampUsers
      )
    );
  };

  users.extraUsers.yt-music-dl = {
    description = "Music downloader using yt-dlp";
    home = "/home/yt-music-dl";
    createHome = true;
    isSystemUser = true;
    group = "syncthing";
  };
}
