{ lib, ... }:
with lib;
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
  errorPageOpts = {
    extraConfig = ''
      ${errorPageDirectives}
    '';

    locations = {
      "= /error.html".extraConfig = ''
        root /var/www;
        ssi on;
        internal;
      '';

      "~ \.(html|ico|webp|png)$".extraConfig = ''
        root /var/www;
        try_files $uri @default;
      '';

      "@default".extraConfig = "";
    };
  };
  addErrorPageOpts = opts: mkMerge [ errorPageOpts opts ];
  denyWriteMethods = "limit_except GET PROPFIND OPTIONS { deny all; }";
}
