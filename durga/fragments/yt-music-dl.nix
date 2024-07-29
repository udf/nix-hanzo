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
    "Black Out Records" = "https://www.youtube.com/channel/UCr_af7byyrsIKPVY5E7ZiqA/videos";
    "BlackmillMusic" = "https://www.youtube.com/channel/UCH1-EnWEmTSECo-gDIweFDA/videos";
    "Blackout Music" = "https://www.youtube.com/channel/UCXLGu6onmiH8ZA_i-dIO5Lg/videos";
    "Camellia" = "https://www.youtube.com/channel/UCV4ggxLd_Vz-I-ePGSKfFog/videos";
    "Cider Party" = "https://www.youtube.com/c/CiderParty/videos";
    "Circus Records" = "https://www.youtube.com/c/circusrecords/videos";
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
    "Monstercat" = "https://www.youtube.com/channel/UCJ6td3C9QlPO9O_J5dF4ZzA/videos";
    "MrMoMMusic" = "https://www.youtube.com/c/MrMoMMusic/videos";
    "MrSuicideSheep" = "https://www.youtube.com/channel/UC5nc_ZtjKW1htCVZVRxlQAQ/videos";
    "nanobii" = "https://www.youtube.com/channel/UCz3hLJ8YpJSippp8LHjpwjg/videos";
    "NoCopyrightSounds" = "https://www.youtube.com/channel/UC_aEa8K-EOJ3D6gOs7HcyNg/videos";
    "NXS" = "https://www.youtube.com/channel/UCl4UOc8h1ZnO-inFPgAu7gw/videos";
    "Owata P" = "https://www.youtube.com/playlist?list=PLTHHOGhQjO3Lau2C605abjcHLV4L5n67x";
    "OxiDaksi" = "https://www.youtube.com/c/OxiDaksi/videos";
    "Proximity" = "https://www.youtube.com/channel/UC3ifTl5zKiCAhHIBQYcaTeg/videos";
    "ReclusiveLemming" = "https://www.youtube.com/@ReclusiveLemming/videos";
    "Reinelex Music" = "https://www.youtube.com/c/Reinelex/videos";
    "roboctopus" = "https://www.youtube.com/channel/UCVNu8yd7tptY8d3EA_PHmkw/videos";
    "S3RL" = "https://www.youtube.com/channel/UCb6JTMjrHZCYFD9Y04CBk9g/videos";
    "Solar Heavy" = "https://www.youtube.com/c/SolarHeavy/videos";
    "StephenWalking" = "https://www.youtube.com/channel/UCiprAA9XNf1DjXJgNkck3yQ/videos";
    "Strobe Music" = "https://www.youtube.com/c/StrobeMusic/videos";
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
    "asc77"
    "astrophysicsbrazil"
    "atariteenageriot"
    "au5music"
    "be4vtyfall"
    "besidesyou"
    "bkode"
    "blackballoonss"
    "blackoutrec"
    "blksmiith"
    "breakbchild"
    "bye2"
    "chipzelmusic"
    "clonepa"
    "clowncore"
    "cooldownreduction"
    "crashfaster"
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
    "geoxor"
    "glitchtrode"
    "gnbchili"
    "goreshit"
    "goreshitarchive"
    "gravitasrecordings"
    "gutterpink"
    "harmfullogic666"
    "hkmori"
    "hxlyxo"
    "ibelieveinangels"
    "idrcauaurltm"
    "igorrr"
    "imkotori"
    "iwakura1144"
    "iwannabeawitch"
    "ixfalls"
    "jacksonifyer"
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
    "lvstslvt"
    "lxchee"
    "lydels"
    "m0-ney"
    "machinegirl"
    "madbreaks"
    "maritumix"
    "masterbootrecord"
    "mayyro"
    "midbooze"
    "mimideath"
    "mimosa"
    "mindvacy"
    "monstercatmedia"
    "myheadhurts"
    "nakedleisure"
    "nanode"
    "nanoray"
    "nastyrhythm"
    "nfract"
    "nitgrit"
    "noagreements"
    "noisechannel"
    "notnedaj"
    "nxcho"
    "opalfruits"
    "orqzeu"
    "owslarecords"
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
    "strxwberrymilk"
    "stupiddecisions"
    "suicidality"
    "synqqq"
    "synthion"
    "takahiro-fks"
    "tami-tomi"
    "theworstlabel"
    "tokyopill"
    "tonroshi"
    "toomuchofme"
    "treyfrey"
    "turquoisedeath"
    "undreamedpanic"
    "untitledexe"
    "usedcvnt"
    "vertigoaway"
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
  ];
  tmpDir = "/home/yt-music-dl/tmp";
  common-args = "--no-progress --no-post-overwrites --add-metadata";
  music-filter = "--match-filter 'duration >= 90 & duration <= 660 & original_url!*=/shorts/'";
  getDownloadCmd = { dir, url, archive ? dir, filter ? music-filter }: ''
    yt-dlp ${common-args} -o '${dir}/%(title)s-%(id)s.%(ext)s' --download-archive '${archive}.txt' \
    ${filter} \
    -ciwx -f bestaudio \
    --sleep-interval 10 \
    --add-metadata --replace-in-metadata 'album' '.' "" --parse-metadata 'title:%(track)s' --parse-metadata 'uploader:%(artist)s' '${url}' || true; sleep 60
  '';
  getBandcampCmd = user: ''
    yt-dlp ${common-args} -ix -f 'flac/mp3' --download-archive '${user}.txt' \
    -o '${user}/%(album,track)s/%(playlist_index)s. %(title)s.%(ext)s' \
    https://${user}.bandcamp.com/music || true; sleep 30
  '';
  musicDir = "/sync/downloads/lossy-music";
in
{
  systemd = {
    timers.yt-music-dl = {
      wantedBy = [ "timers.target" ];
      partOf = [ "yt-music-dl.service" ];
      timerConfig = {
        OnCalendar = "daily";
        Persistent = true;
      };
    };
    services.yt-music-dl = {
      after = [ "network.target" ];
      before = [ "music-gain-tag.service" ];
      path = [
        "/home/yt-music-dl/.local"
        pkgs.ffmpeg
        pkgs.rsync
      ];
      serviceConfig = {
        Type = "oneshot";
        User = "yt-music-dl";
        WorkingDirectory = "/home/yt-music-dl";
        UMask = "0000";
      };

      script = ''
        ${pkgs.python310.pkgs.pip}/bin/pip install --break-system-packages --user -U yt-dlp

        # copy download archives
        rsync -rmv \
        --include=favourites/ \
        --include=lossy-downloads/ \
        --include=lossy-downloads/yt/ \
        --include=lossy-downloads/bandcamp/ \
        --include="*.txt" \
        --exclude="*" \
        ${musicDir}/ ${tmpDir}/

        cd ${tmpDir}/favourites
        ${builtins.concatStringsSep "\n"
          (mapAttrsToList (k: v: getDownloadCmd { dir = k; url = v; filter = ""; }) playlists)}

        cd ${tmpDir}/lossy-downloads/yt
        ${builtins.concatStringsSep "\n"
          (mapAttrsToList (k: v: getDownloadCmd { dir = "%(upload_date)s/${k}"; archive = k; url = v; }) channels)}

        cd ${tmpDir}/lossy-downloads/bandcamp
        ${builtins.concatStringsSep "\n" (map getBandcampCmd bandcampUsers)}

        # move downloads to music dir
        rsync -rv --remove-source-files ${tmpDir}/ ${musicDir}/
        find ${tmpDir} -type d -empty -delete
      '';
    };
  };

  users.extraUsers.yt-music-dl = {
    description = "YT playlist downloader";
    home = "/home/yt-music-dl";
    createHome = true;
    isSystemUser = true;
    group = "syncthing";
  };
}