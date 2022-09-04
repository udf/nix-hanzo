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
    "astrophysicsbrazil"
    "atariteenageriot"
    "au5music"
    "blacksmithfl"
    "breakbchild"
    "chipzelmusic"
    "clowncore"
    "dissolve3"
    "dredcollective"
    "dubmood"
    "end-user"
    "familyjules7x"
    "glitchtrode"
    "gnbchili"
    "goreshit"
    "goreshitarchive"
    "gravitasrecordings"
    "harmfullogic666"
    "iwannabeawitch"
    "jacksonifyer"
    "joy-less"
    "kaizoslumber"
    "knowermusic"
    "lapfox"
    "llwll"
    "lolinearly20s"
    "lostfrog"
    "lukhash"
    "m0-ney"
    "machinegirl"
    "masterbootrecord"
    "mimosa"
    "monstercatmedia"
    "myheadhurts"
    "nanode"
    "nanoray"
    "nfract"
    "nitgrit"
    "noagreements"
    "notnedaj"
    "orqzeu"
    "plasmapool"
    "rispaa"
    "sageisdead"
    "sfork"
    "sorryaboutmyface"
    "spurme"
    "strxwberrymilk"
    "stupiddecisions"
    "synthion"
    "theworstlabel"
    "tokyopill"
    "toomuchofme"
    "treyfrey"
    "untitledexe"
    "vertigoaway"
    "vixenvy"
    "yurisimaginarylabel"
    "zenithplight"
  ];
  getDownloadCmd = { dir, url, archive ? dir }: ''
    yt-dlp -o '${dir}/%(title)s-%(id)s.%(ext)s' --download-archive '${archive}.txt' \
    --match-filter 'duration >= 90 & duration <= 660' \
    --no-progress --no-post-overwrites -ciwx -f bestaudio \
    --add-metadata --replace-in-metadata 'album' '.' "" --parse-metadata 'title:%(track)s' --parse-metadata 'uploader:%(artist)s' '${url}' || true
  '';
  getBandcampCmd = user: ''
    yt-dlp --add-metadata -ix -f 'flac/mp3' --download-archive '${user}.txt' \
    --no-post-overwrites -o '${user}/%(album,track)s/%(playlist_index)s. %(title)s.%(ext)s' \
    https://${user}.bandcamp.com/music || true
  '';
  musicDir = config.utils.storageDirs.dirs.music.path;
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
      ];
      serviceConfig = {
        Type = "oneshot";
        User = "yt-music-dl";
        WorkingDirectory = "${musicDir}";
      };

      script = ''
        ${pkgs.python39.pkgs.pip}/bin/pip install --user -U yt-dlp
        cd ${musicDir}/favourites
        ${builtins.concatStringsSep "\n"
          (mapAttrsToList (k: v: getDownloadCmd { dir = k; url = v; }) playlists)}
        cd ${musicDir}/pending/yt
        ${builtins.concatStringsSep "\n"
          (mapAttrsToList (k: v: getDownloadCmd { dir = "%(upload_date)s/${k}"; archive = k; url = v; }) channels)}
        cd ${musicDir}/pending/bandcamp
        ${builtins.concatStringsSep "\n" (map getBandcampCmd bandcampUsers)}
      '';
    };
  };

  users.extraUsers.yt-music-dl = {
    description = "YT playlist downloader";
    home = "/home/yt-music-dl";
    createHome = true;
    isSystemUser = true;
    group = "yt-music-dl";
  };
  users.groups.yt-music-dl = { };

  utils.storageDirs.dirs.music.users = [ "yt-music-dl" ];
}
