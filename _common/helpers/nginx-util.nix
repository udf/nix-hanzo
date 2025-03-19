{ lib, pkgs, ... }:
with lib;
let
  staticDir = import ../packages/nginx-static { inherit lib pkgs; };
in
rec {
  statusCodes = {
    "400" = "Bad Request";
    "401" = "Unauthorized";
    "402" = "Payment Required";
    "403" = "Forbidden";
    "404" = "Not Found";
    "405" = "Method Not Allowed";
    "406" = "Not Acceptable";
    "407" = "Proxy Authentication Required";
    "408" = "Request Timeout";
    "409" = "Conflict";
    "410" = "Gone";
    "411" = "Length Required";
    "412" = "Precondition Failed";
    "413" = "Payload Too Large";
    "414" = "Request URI Too Long";
    "415" = "Unsupported Media Type";
    "416" = "Requested Range Not Satisfiable";
    "417" = "Expectation Failed";
    "418" = "I'm a teapot";
    "421" = "Misdirected Request";
    "422" = "Unprocessable Entity";
    "423" = "Locked";
    "424" = "Failed Dependency";
    "425" = "Too Early";
    "426" = "Upgrade Required";
    "428" = "Precondition Required";
    "429" = "Too Many Requests";
    "431" = "Request Header Fields Too Large";
    "451" = "Unavailable For Legal Reasons";
    "500" = "Internal Server Error";
    "501" = "Not Implemented";
    "502" = "Bad Gateway";
    "503" = "Service Unavailable";
    "504" = "Gateway Timeout";
    "505" = "HTTP Version Not Supported";
    "506" = "Variant Also Negotiates";
    "507" = "Insufficient Storage";
    "508" = "Loop Detected";
    "510" = "Not Extended";
    "511" = "Network Authentication Required";
    "599" = "Network Connect Timeout Error";
  };

  errorPageDirectives = "error_page ${concatStringsSep " " (attrNames statusCodes)} /error.html;";
  errorPageHttpConfig = ''
    map $hostname $err_img_prefix {
      default "taiga";
      "phanes" "samcat";
    }

    map $status $status_text {
      ${
        concatStringsSep "\n" (mapAttrsToList
          (k: v: "${k} ${lib.strings.escapeNixString v};") statusCodes
        )
      }
      default "Something went wrong";
    }

    map $server_protocol $set_gzip_gzip_if_http1 {
      "~^HTTP/1" "gzip, gzip";
      default "";
    }
  '';
  errorPageOpts = {
    extraConfig = ''
      ${errorPageDirectives}
    '';

    locations = {
      "= /error.html".extraConfig = ''
        root ${staticDir};
        ssi on;
        internal;
      '';

      "^~ /err_img/".extraConfig = ''
        alias ${staticDir}/;
        try_files $uri =404;
        internal;
      '';

      "= /favicon.ico".extraConfig = ''
        root ${staticDir};
        try_files $uri =404;
      '';

      "@default".extraConfig = "";
    };
  };
  addErrorPageOpts = opts: mkMerge [ errorPageOpts opts ];
  denyWriteMethods = "limit_except GET PROPFIND OPTIONS { deny all; }";
  gzipBombConfig = ''
    root /var/www;
    types { } default_type "text/plain; charset=utf-8";
    add_header Content-Encoding "gzip, gzip";
    add_header Transfer-Encoding $set_gzip_gzip_if_http1;
    try_files /100g_9_9.gzip.gzip =444;
    access_log off;
  '';
}
