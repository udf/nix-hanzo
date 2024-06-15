import qs from "querystring";
import crypto from "crypto";

var DEFAULT_TOKEN_PARAM = 'sl_token';

// Gets the value of the token provided in the request
function arg_token(r) {
  var param_name = r.variables.sl_param || DEFAULT_TOKEN_PARAM;
  return r.args[param_name] || '';
}

// Returns a URL that should be used to generate the token
function hashable_url(r) {
  var param_name = r.variables.sl_param || DEFAULT_TOKEN_PARAM;
  delete r.args[param_name];
  return `${r.uri}?${qs.stringify(r.args)} ${process.env.SL_SECRET_KEY}`;
}

// Returns the expected hash for this request
function expected_hash(r) {
  return crypto.createHash('md5').update(hashable_url(r)).digest('base64url');
}

// Generates the shareable URL by setting the token parameter to the expected one
function shareable_url(r) {
  var param_name = r.variables.sl_param || DEFAULT_TOKEN_PARAM;
  r.args[param_name] = expected_hash(r);
  return `${r.uri}?${qs.stringify(r.args)}`;
}

export default {arg_token, hashable_url, expected_hash, shareable_url};