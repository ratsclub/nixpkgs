{ lib
, python3Packages
, fetchFromGitHub
}:

let
  stripe_7_14_0 = python3Packages.stripe.overrideAttrs (old: rec {
    version = "7.14.0";
    src = (old.src.override {
      version = "${version}";
      hash = "sha256-VWv6hviymLZm/yyqDXVO4Z7OUhWdEqRe192wLardF5k=";
    });
  });
  tinycss2_1_2_1 = python3Packages.tinycss2.overrideAttrs (old: rec {
    version = "1.2.1";
    src = (old.src.override {
      version = "${version}";
      hash = "sha256-vWv6hviymLZm/yyqDXVO4Z7OUhWdEqRe192wLardF5k=";
    });
  });
in

python3Packages.buildPythonApplication
rec {
  pname = "mataroa";
  version = "0-unstable-2024-07-20";

  src = fetchFromGitHub {
    owner = "mataroa-blog";
    repo = pname;
    rev = "fbb6ef628935af95a03a70a28e176e588418c2da";
    hash = "sha256-7b3KA/KQgA/uL6fBtVIO9e0Nvx3ERJZEAgNoLkvcXDw=";
  };

  build-system = with python3Packages; [ setuptools ];

  dependencies = with python3Packages; [
    django_5
    psycopg2
    gunicorn
    markdown
    pygments
    bleach
    stripe_7_14_0
  ] ++ bleach.optional-dependencies.css;

  postPatch = ''
    substituteInPlace requirements.txt \
      --replace-fail psycopg2-binary psycopg2
  '';

  # tests require network access
  # doCheck = false;


  preBuild = ''
    cat > setup.py << EOF
    from setuptools import setup, find_packages

    with open('requirements.txt') as f:
      install_requires = f.read().splitlines()

    setup(
      name='${pname}',
      version='0.0.1',
      install_requires=install_requires,
      packages=find_packages(),
      scripts=[
        'manage.py',
      ],
      entry_points={
        # example: file some_module.py -> function main
        #'console_scripts': ['someprogram=some_module:main']
      },
    )
    EOF
  '';

  installPhase = ''
    cat setup.py
    mkdir -p $out/opt/${pname}
    cp -r . $out/opt/${pname}
    chmod +x $out/opt/${pname}/manage.py
    makeWrapper $out/opt/${pname}/manage.py $out/bin/${pname} \
      --prefix PYTHONPATH : "$PYTHONPATH"
  '';
}
