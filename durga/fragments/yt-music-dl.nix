{ config, lib, pkgs, ... }:
with lib;
let
  playlists = {
    "wubwubwub" = "https://www.youtube.com/playlist?list=PLjgVd_07uAd95EmLlzcafgYjwIqHnIDUg";
    "cool stuff" = "https://www.youtube.com/playlist?list=PLjgVd_07uAd9LSrikWrxkUKQs9NmVKx69";
    "weeb shit" = "https://www.youtube.com/playlist?list=PLjgVd_07uAd-JL2Wz1Zr9q7aVKG8pBdZA";
  };
  channels = {
    "Absurdismworld" = "https://www.youtube.com/c/Absurdismworldsarchivechannel";
    "AirwaveMusicTV" = "https://www.youtube.com/c/AirwaveMusicTV";
    "Astrophysics" = "https://www.youtube.com/c/Astrophysicsynth";
    "Au5" = "https://www.youtube.com/channel/UCznSBwEKa4xU8HmbEXCv6Yw";
    "Black Out Records" = "https://www.youtube.com/channel/UCr_af7byyrsIKPVY5E7ZiqA";
    "BlackmillMusic" = "https://www.youtube.com/channel/UCH1-EnWEmTSECo-gDIweFDA";
    "Blackout Music" = "https://www.youtube.com/channel/UCXLGu6onmiH8ZA_i-dIO5Lg";
    "Camellia" = "https://www.youtube.com/channel/UCV4ggxLd_Vz-I-ePGSKfFog";
    "Cider Party" = "https://www.youtube.com/c/CiderParty";
    "Circus Records" = "https://www.youtube.com/c/circusrecords";
    "DjEphixa" = "https://www.youtube.com/channel/UCGfBXs27YPr0U8CFim-RefQ";
    "DJT" = "https://www.youtube.com/channel/UC09L_fOVn3Tg0NKNJl9njCA";
    "Dubstep uNk" = "https://www.youtube.com/c/DubstepuNkOfficial";
    "DubstepGutter" = "https://www.youtube.com/channel/UCG6QEHCBfWZOnv7UVxappyw";
    "Far Too Loud" = "https://www.youtube.com/channel/UCRpyx8avnqPAaAbLIWDFlpw";
    "Fox Stevenson" = "https://www.youtube.com/channel/UClAxKFEVmERwGhcUhpCzlWw";
    "Hay Tea" = "https://www.youtube.com/c/HayFlavouredTea";
    "HiTech Trance" = "https://www.youtube.com/c/hitechtrance";
    "iblank2apples" = "https://www.youtube.com/c/iblank2apples";
    "INF1N1TE" = "https://www.youtube.com/channel/UC9ivTxVsmSPFvQzUPMb9JgA";
    "Inspector Dubplate" = "https://www.youtube.com/user/InspectorDubplate";
    "K-391" = "https://www.youtube.com/channel/UC1XoTfl_ctHKoEbe64yUC_g";
    "luggi spikes" = "https://www.youtube.com/channel/UC5_I30UR32Pr-274nkXHQ_g";
    "Madeon" = "https://www.youtube.com/channel/UCqMDNf3Pn5L7pcNkuSEeO3w";
    "MDK" = "https://www.youtube.com/c/MDKOfficialYT";
    "Monstercat" = "https://www.youtube.com/channel/UCJ6td3C9QlPO9O_J5dF4ZzA";
    "MrMoMMusic" = "https://www.youtube.com/c/MrMoMMusic";
    "MrSuicideSheep" = "https://www.youtube.com/channel/UC5nc_ZtjKW1htCVZVRxlQAQ";
    "nanobii" = "https://www.youtube.com/channel/UCz3hLJ8YpJSippp8LHjpwjg";
    "NoCopyrightSounds" = "https://www.youtube.com/channel/UC_aEa8K-EOJ3D6gOs7HcyNg";
    "NXS" = "https://www.youtube.com/channel/UCl4UOc8h1ZnO-inFPgAu7gw";
    "Owata P" = "https://www.youtube.com/playlist?list=PLTHHOGhQjO3Lau2C605abjcHLV4L5n67x";
    "OxiDaksi" = "https://www.youtube.com/c/OxiDaksi";
    "Proximity" = "https://www.youtube.com/channel/UC3ifTl5zKiCAhHIBQYcaTeg";
    "ReclusiveLemming" = "https://www.youtube.com/user/ReclusiveLemming";
    "Reinelex Music" = "https://www.youtube.com/c/Reinelex";
    "roboctopus" = "https://www.youtube.com/channel/UCVNu8yd7tptY8d3EA_PHmkw";
    "S3RL" = "https://www.youtube.com/channel/UCb6JTMjrHZCYFD9Y04CBk9g";
    "Solar Heavy" = "https://www.youtube.com/c/SolarHeavy";
    "StephenWalking" = "https://www.youtube.com/channel/UCiprAA9XNf1DjXJgNkck3yQ";
    "Strobe Music" = "https://www.youtube.com/c/StrobeMusic";
    "SuicideSheeep" = "https://www.youtube.com/user/SuicideSheeep";
    "Syfer Music" = "https://www.youtube.com/c/SyferMusic";
    "Synthion" = "https://www.youtube.com/playlist?list=PLfhXxN0xXN4J22w4cPl1s5YyjFmzKqwed";
    "Tasty" = "https://www.youtube.com/channel/UC0n9yiP-AD2DpuuYCDwlNxQ";
    "TCB" = "https://www.youtube.com/c/TCBpon";
    "Technical Hitch" = "https://www.youtube.com/c/hitechsergio/";
    "The Dub Rebellion" = "https://www.youtube.com/channel/UCH3V-b6weBfTrDuyJgFioOw";
    "Trap City" = "https://www.youtube.com/channel/UC65afEgL62PGFWXY7n6CUbA";
    "Trap Nation" = "https://www.youtube.com/channel/UCa10nxShhzNrCE1o2ZOPztg";
    "UKF DNB" = "https://www.youtube.com/c/UKFDrumandBass";
    "UKF Dubstep" = "https://www.youtube.com/channel/UCfLFTP1uTuIizynWsZq2nkQ";
    "UndreamedPanic" = "https://www.youtube.com/channel/UC5u0K5MNm_P5jmK3ByM0lpw";
    "Wobblecraft" = "https://www.youtube.com/channel/UCqrxoI6XuLkVEY4S-oXibnA";
    "xMerciAx" = "https://www.youtube.com/playlist?list=PLb1K-m5QT703CWP_Jhyblpwasjrgl_W81";
    "Yume" = "https://www.youtube.com/c/YumeNetwork";
  };
  bandcampUsers = [
    "0101"
    "633397"
    "aak3"
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
    "cvmpliant"
    "dadaihaiji"
    "darkman007"
    "dissolve3"
    "dokxid"
    "dracodracodracodraco"
    "dredcollective"
    "dubmood"
    "eightiesheadachetape"
    "end-user"
    "erythh"
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
    "ibelieveinangels"
    "idrcauaurltm"
    "igorrr"
    "imkotori"
    "iwannabeawitch"
    "jacksonifyer"
    "jacksonifyer"
    "jayakiba"
    "joy-less"
    "kaizoslumber"
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
    "masterbootrecord"
    "mayyro"
    "midbooze"
    "mimosa"
    "mindvacy"
    "monstercatmedia"
    "myheadhurts"
    "nanode"
    "nanoray"
    "nastyrhythm"
    "nfract"
    "nitgrit"
    "noagreements"
    "noisechannel"
    "notnedaj"
    "orqzeu"
    "owslarecords"
    "paradoxically"
    "pisca"
    "plasmapool"
    "princewhateverer"
    "proloxx"
    "psykorecords"
    "purityfilter"
    "quantumdigitsrecordings"
    "rampagerecordings"
    "resurrectionrecords"
    "rispaa"
    "rorynearly20s"
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
    "vixenvy"
    "voipetsu"
    "voodoo-hoodoo"
    "vrtlhvn"
    "yakuithemaid1"
    "yonkagor"
    "youngscrolls"
    "yungkkun"
    "yurisimaginarylabel"
  ];
  tmpDir = "/home/yt-music-dl/tmp";
  common-args = "--no-progress --no-post-overwrites --add-metadata";
  music-filter = "--match-filter 'duration >= 90 & duration <= 660 & original_url!*=/shorts/'";
  getDownloadCmd = { dir, url, archive ? dir, filter ? music-filter }: ''
    yt-dlp ${common-args} -o '${dir}/%(title)s-%(id)s.%(ext)s' --download-archive '${archive}.txt' \
    ${filter} \
    -ciwx -f bestaudio \
    --add-metadata --replace-in-metadata 'album' '.' "" --parse-metadata 'title:%(track)s' --parse-metadata 'uploader:%(artist)s' '${url}' || true
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