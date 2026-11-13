local ADDON, ns = ...

local locale = GetLocale()
if locale ~= "esES" and locale ~= "esMX" then
    return
end

local L = ns.L

local translations = {
    ADDON_NAME = "FishForever",

    SLASH_HELP_HEADER = "Comandos disponibles:",
    SLASH_HELP_ENTRY = "  /ff %s - %s",
    SLASH_HELP_HELP = "Muestra esta ayuda.",
    SLASH_HELP_VERSION = "Muestra la versión del addon.",
    SLASH_HELP_DIAG = "Comprueba qué API del cliente hay y guarda el resultado en FishForeverDB.diag.",
    SLASH_HELP_DEBUG = "Activa o desactiva el registro de eventos guardado en FishForeverDB.debugLog.",
    SLASH_HELP_FISH = "Activa o desactiva el modo pesca: equipa una caña de pescar o restaura tu equipo anterior.",
    SLASH_HELP_MINIMAP = "Muestra u oculta el botón del minimapa.",

    MSG_UNKNOWN_COMMAND = "Comando desconocido: %s.",
    MSG_HELP_HINT = "Escribe /ff help para ver los comandos disponibles.",
    MSG_VERSION = "Versión %s.",
    VERSION_UNKNOWN = "desconocida",
    SLASH_HELP_STATS = "Muestra u oculta la ventana de la sesión de pesca.",
    MSG_DATA_NEWER = "Tus datos guardados son de una versión más nueva de FishForever. No se modificarán; actualiza el addon.",

    MSG_DIAG_IN_COMBAT = "El diagnóstico no puede ejecutarse en combate. Inténtalo de nuevo al salir.",
    MSG_DIAG_SAVED = "Diagnóstico guardado (%d encontradas, %d ausentes). Haz /reload y lee FishForeverDB.diag.",
    MSG_DIAG_FAILED = "No se pudo completar el diagnóstico. Revisa el chat para más detalles.",
    MSG_DIAG_NOT_READY = "FishForever todavía se está cargando. Inténtalo de nuevo en un momento.",
    MSG_DEBUG_ON = "Registro de eventos activado. Pesca unas cuantas veces, haz /reload y lee FishForeverDB.debugLog.",
    MSG_DEBUG_OFF = "Registro de eventos desactivado.",

    MSG_FISH_IN_COMBAT = "El modo pesca no puede cambiar en combate. Se aplicará al terminar.",
    MSG_FISH_NO_POLE = "No hay ninguna caña de pescar en las bolsas.",
    MSG_FISH_ENTERED = "Modo pesca activado.",
    MSG_FISH_EXITED = "Modo pesca desactivado.",
    MSG_FISH_MISSING_ITEM = "No se pudo restaurar %s: ya no está en las bolsas.",
    BINDING_CAST_LOOT = "Lanzar / recoger (una pulsación = una acción)",
    STATUS_LOOT_KEY = "%s: recoger",
    STATUS_LOOT_MOUSE = "Clic derecho en el corcho",
    STATUS_CAUGHT = "¡Captura!",
    STATUS_ESCAPED = "Se escapó",
    TIP_CAST = "Clic izquierdo o tecla: lanzar.",
    TIP_LOOT = "Con el corcho en el agua, la misma tecla lo recoge (o clic derecho sobre el corcho).",
    TIP_MODE = "Clic derecho: modo pesca (equipa la caña / devuelve el equipo anterior).",
    TIP_MOVE = "Mayús + arrastrar: mover. /ff lock para bloquearlo.",
    TIP_NO_KEY = "Asigna una tecla en Atajos de teclado > Accesorios > FishForever para recoger con una pulsación.",
    TIP_MINIMAP_LEFT = "Clic izquierdo: muestra u oculta el botón flotador.",
    TIP_MINIMAP_RIGHT = "Clic derecho: activa o desactiva el modo pesca.",
    TIP_MINIMAP_SHIFT = "Mayús + clic izquierdo: estadísticas de la sesión.",
    TIP_MINIMAP_DRAG = "Arrastrar: mover alrededor del minimapa.",
    STATUS_MINIMAP_ON = "Modo pesca: activado.",
    STATUS_MINIMAP_OFF = "Modo pesca: desactivado.",
    MSG_NOT_IN_COMBAT = "No se puede hacer en combate.",
    SLASH_HELP_BUTTON = "Muestra u oculta el botón flotador.",
    SLASH_HELP_LOCK = "Bloquea o desbloquea la posición del botón.",
    MSG_LOCKED = "Botón bloqueado.",
    MSG_UNLOCKED = "Botón desbloqueado: Mayús + arrastrar para moverlo.",
    SLASH_HELP_SOUND = "Activa o desactiva el realce de sonido al pescar.",
    MSG_SOUND_ON = "Realce de sonido activado: efectos al máximo y música baja mientras pescas para oír el chapoteo.",
    MSG_SOUND_OFF = "Realce de sonido desactivado.",
    MSG_MINIMAP_ON = "Botón del minimapa mostrado.",
    MSG_MINIMAP_OFF = "Botón del minimapa oculto.",
    CONSENT_TITLE = "FishForever - Privacidad",
    CONSENT_TEXT = "FishForever comparte tus hallazgos de pesca con tu grupo y hermandad para que los datos de bancos y capturas sean más precisos. Nos beneficia a todos. Puedes desactivarlo en Opciones.",
    CONSENT_OK = "Entendido",
    CONSENT_OPTIONS = "Opciones",
    CONSENT_SHARE_GROUP = "Compartir con mi grupo",
    CONSENT_SHARE_GUILD = "Compartir con mi hermandad",
    CONSENT_NOTE = "Solo ubicaciones de bancos, qué se pesca y dónde, y recuentos. Nunca el nombre de tu personaje.",
    SLASH_HELP_PRIVACY = "Muestra el aviso de privacidad y las opciones de compartir.",

    STATS_TITLE = "Sesión de pesca",
    STATS_TIME = "Tiempo pescando",
    STATS_CASTS = "Lanzamientos",
    STATS_CATCHES = "Capturas",
    STATS_ESCAPES = "Escapados",
    STATS_PER_HOUR = "Capturas por hora",
    STATS_SUCCESS = "Éxito",
    STATS_ITEMS = "Pescado",
    STATS_MORE = "+%d más",
    STATS_EMPTY = "Aún no has pescado nada.",
    STATS_RESET = "Reiniciar",
    STATS_RESET_CONFIRM = "¿Seguro?",
    STATS_CLOSE = "x",
}

for key, value in pairs(translations) do
    L[key] = value
end
