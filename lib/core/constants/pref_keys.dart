//Niyə bu fayl lazımdır? Açar sözləri ('isFirstLaunch' kimi mətnləri) hər yerdə əl ilə yazmaq səhv ehtimalını artırır (məsələn bir yerdə 'isFirstLaunch', başqa yerdə səhvən 'isFirstlaunch' yazsan, bu, səssiz bug yaradar).
//Bunun əvəzinə, bir dəfə, mərkəzi yerdə sabit dəyər kimi saxlayırıq.
class PrefsKeys {
  static const String isFirstLaunch = 'isFirstLaunch';
}
