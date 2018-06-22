# Description:
#   Allows Hubot to know many languages.
#
# Commands:
#   hubot translate <phrase> - Searches for a translation for the <phrase>.
#   hubot translate from <source> to <target> <phrase> - Translates <phrase> from <source> into <target>.
#
#author:
#   https://github.com/hubot-scripts/hubot-google-translate

translate = require('google-translate-api')
languages =
  "af": "Afrikaans",
  "sq": "Albanian",
  "ar": "Arabic",
  "az": "Azerbaijani",
  "eu": "Basque",
  "bn": "Bengali",
  "be": "Belarusian",
  "bg": "Bulgarian",
  "ca": "Catalan",
  "zh-CN": "Simplified Chinese",
  "zh-TW": "Traditional Chinese",
  "hr": "Croatian",
  "cs": "Czech",
  "da": "Danish",
  "nl": "Dutch",
  "en": "English",
  "eo": "Esperanto",
  "et": "Estonian",
  "tl": "Filipino",
  "fi": "Finnish",
  "fr": "French",
  "gl": "Galician",
  "ka": "Georgian",
  "de": "German",
  "el": "Greek",
  "gu": "Gujarati",
  "ht": "Haitian Creole",
  "iw": "Hebrew",
  "hi": "Hindi",
  "hu": "Hungarian",
  "is": "Icelandic",
  "id": "Indonesian",
  "ga": "Irish",
  "it": "Italian",
  "ja": "Japanese",
  "kn": "Kannada",
  "ko": "Korean",
  "la": "Latin",
  "lv": "Latvian",
  "lt": "Lithuanian",
  "mk": "Macedonian",
  "ms": "Malay",
  "mt": "Maltese",
  "no": "Norwegian",
  "fa": "Persian",
  "pl": "Polish",
  "pt": "Portuguese",
  "ro": "Romanian",
  "ru": "Russian",
  "sr": "Serbian",
  "sk": "Slovak",
  "sl": "Slovenian",
  "es": "Spanish",
  "sw": "Swahili",
  "sv": "Swedish",
  "ta": "Tamil",
  "te": "Telugu",
  "th": "Thai",
  "tr": "Turkish",
  "uk": "Ukrainian",
  "ur": "Urdu",
  "vi": "Vietnamese",
  "cy": "Welsh",
  "yi": "Yiddish"

getCode = (language,languages) ->
  for code, lang of languages
      return code if lang.toLowerCase() is language.toLowerCase()

module.exports = (robot) ->
  language_choices = (language for _, language of languages).sort().join('|')
  pattern = new RegExp('translate(?: me)?' +
                       "(?: from (#{language_choices}))?" +
                       "(?: (?:in)?to (#{language_choices}))?" +
                       '(.*)', 'i')

  robot.respond pattern, (msg) ->
    term   = "\"#{msg.match[3]?.trim()}\""
    origin = if msg.match[1] isnt undefined then getCode(msg.match[1], languages) else 'auto'
    target = if msg.match[2] isnt undefined then getCode(msg.match[2], languages) else 'en'

    translate(term, {from: origin, to: target}).then (data) ->
      ori = if  origin is 'auto' then data.from.language.iso else origin
      msg.send "from #{languages[ori]} to #{languages[target]}: "+data.text
    .catch (err) ->
      msg.send "Failed to parse Google translate response"
      robot.emit 'error', err
