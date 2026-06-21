extends Node

signal locale_changed(locale: String)

@export var supported_locales: Array[String] = ["en", "es", "fr", "de", "ja"]
@export var fallback_locale: String = "en"

func set_locale(locale: String) -> void:
    if not supported_locales.has(locale):
        locale = fallback_locale
    TranslationServer.set_locale(locale)
    locale_changed.emit(locale)

func get_locale() -> String:
    return TranslationServer.get_locale()

func t(key: String) -> String:
    return tr(key)

func format_t(key: String, values: Dictionary) -> String:
    var text: String = tr(key)
    for k in values.keys():
        text = text.replace("{" + str(k) + "}", str(values[k]))
    return text

func pseudo_preview(key: String) -> String:
    return str(TranslationServer.pseudolocalize(key))
