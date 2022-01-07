{pkgs, themes }: { 
  theme ? "Ziro",
  colorScheme ? "",
  thirdParyThemes ? {},
  thirdParyExtensions ? {},
  thirdParyCustomApps ? {},
  enabledExtensions ? [],
  enabledCustomApps ? [],
  spotifyLaunchFlags ? "",
  injectCss ? false,
  replaceColors ? false,
  overwriteAssets ? false,
  disableSentry ? true,
  disableUiLogging ? true,
  removeRtlRule ? true,
  exposeApis ? true,
  disableUpgradeCheck ? true,
  fastUserSwitching ? false,
  visualizationHighFramerate ? false,
  radio ? false,
  songPage ? false,
  experimentalFeatures ? false,
  home ? false,
  lyricAlwaysShow ? false,
  lyricForceNoSync ? false
}:

let
  inherit (pkgs.lib.lists) foldr;
  inherit (pkgs.lib.attrsets) mapAttrsToList;

  # Helper functions
  pipeConcat = foldr (a: b: a + "|" + b) "";
  lineBreakConcat = foldr (a: b: a + "\n" + b) "";
  boolToString = x: if x then "1" else "0";
  makeLnCommands = type: (mapAttrsToList (name: path: "ln -sf ${path} ./${type}/${name}"));

  # Setup spicetify
  spicetifyPkg = pkgs.spicetify-cli;
  spicetify = "SPICETIFY_CONFIG=. ${spicetifyPkg}/bin/spicetify-cli";

  # Dribblish is a theme which needs a couple extra settings
  isDribblish = theme == "Dribbblish";
  
  extraCommands = (if isDribblish then "cp ./Themes/Dribbblish/dribbblish.js ./Extensions \n" else "")
    + (lineBreakConcat (makeLnCommands "Themes" thirdParyThemes))
    + (lineBreakConcat (makeLnCommands "Extensions" thirdParyExtensions))
    + (lineBreakConcat (makeLnCommands "CustomApps" thirdParyCustomApps));

  customAppsFixupCommands = lineBreakConcat (makeLnCommands "Apps" thirdParyCustomApps);
  
  injectCssOrDribblish = boolToString (isDribblish || injectCss);
  replaceColorsOrDribblish = boolToString (isDribblish || replaceColors);
  overwriteAssetsOrDribblish = boolToString (isDribblish || overwriteAssets);

  extensionString = pipeConcat ((if isDribblish then [ "dribbblish.js" ] else []) ++ enabledExtensions);
  customAppsString = pipeConcat enabledCustomApps;
in
pkgs.spotify-unwrapped.overrideAttrs (oldAttrs: rec {
  postInstall=''
    touch $out/prefs
    mkdir Themes
    mkdir Extensions
    mkdir CustomApps

    mkdir -p $out/share/spotify/Apps/zlink/css
    touch $out/share/spotify/Apps/zlink/css/user.css

    find ${themes} -maxdepth 1 -type d -exec ln -s {} Themes \;
    ${extraCommands}
    
    ${spicetify} -q


    sed -i "s;spotify_path            = $;spotify_path            = $out/share/spotify;" config-xpui.ini
    sed -i "s;prefs_path              = $;prefs_path            = $out/prefs;" config-xpui.ini

    cat config-xpui.ini

    ${spicetify} config \
      prefs_path "$out/prefs" \
      current_theme ${theme} \
      ${if 
          colorScheme != ""
        then 
          ''color_scheme "${colorScheme}" \'' 
        else 
          ''\'' }
      ${if 
          extensionString != ""
        then 
          ''extensions "${extensionString}" \'' 
        else 
          ''\'' }
      ${if
          customAppsString != ""
        then 
          ''custom_apps "${customAppsString}" \'' 
        else 
          ''\'' }
      ${if
          spotifyLaunchFlags != ""
        then 
          ''spotify_launch_flags "${spotifyLaunchFlags}" \'' 
        else 
          ''\'' }
      inject_css ${injectCssOrDribblish} \
      replace_colors ${replaceColorsOrDribblish} \
      overwrite_assets ${overwriteAssetsOrDribblish} \
      disable_sentry ${boolToString disableSentry } \
      disable_ui_logging ${boolToString disableUiLogging } \
      remove_rtl_rule ${boolToString removeRtlRule } \
      expose_apis ${boolToString exposeApis } \
      disable_upgrade_check ${boolToString disableUpgradeCheck } \
      experimental_features ${boolToString experimentalFeatures } \


    ${spicetify} backup apply

    cd $out/share/spotify
    ${customAppsFixupCommands}
  '';
})
