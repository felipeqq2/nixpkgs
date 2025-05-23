{
  lib,
  stdenv,
  fetchurl,
  jre,
  makeWrapper,
  versionCheckHook,
}:

stdenv.mkDerivation rec {
  pname = "bfg-repo-cleaner";
  version = "1.15.0";

  jarName = "bfg-${version}.jar";

  src = fetchurl {
    url = "mirror://maven/com/madgag/bfg/${version}/${jarName}";
    hash = "sha256-3+KIWtwpFjeQk/AqgBgSAFNoVsmph78hxJLkUq3v73o=";
  };

  nativeBuildInputs = [ makeWrapper ];
  buildInputs = [ jre ];

  dontUnpack = true;

  installPhase = ''
    mkdir -p $out/share/java
    mkdir -p $out/bin
    cp $src $out/share/java/$jarName
    makeWrapper "${jre}/bin/java" $out/bin/bfg --add-flags "-cp $out/share/java/$jarName com.madgag.git.bfg.cli.Main"
  '';

  nativeInstallCheckInputs = [
    versionCheckHook
  ];
  doInstallCheck = true;
  versionCheckProgram = "${placeholder "out"}/bin/${meta.mainProgram}";
  versionCheckProgramArg = "--version";

  meta = with lib; {
    homepage = "https://rtyley.github.io/bfg-repo-cleaner/";
    # Descriptions taken with minor modification from the homepage of bfg-repo-cleaner
    description = "Removes large or troublesome blobs in a git repository like git-filter-branch does, but faster";
    longDescription = ''
      The BFG is a simpler, faster alternative to git-filter-branch for
      cleansing bad data out of your Git repository history, in particular removing
      crazy big files and removing passwords, credentials, and other private data.

      The git-filter-branch command is enormously powerful and can do things
      that the BFG can't - but the BFG is much better for the tasks above, because
      it's faster (10-720x), simpler (dedicated to just removing things), and
      beautiful (can use Scala instead of bash to script customizations).
    '';
    sourceProvenance = with sourceTypes; [ binaryBytecode ];
    license = licenses.gpl3;
    maintainers = [ maintainers.changlinli ];
    mainProgram = "bfg";
    platforms = platforms.unix;
    downloadPage = "https://mvnrepository.com/artifact/com.madgag/bfg/${version}";
  };

}
