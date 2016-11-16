#/usr/bin/env python

from itertools import product
import sys
import yaml

clangVersions = (
    '3.8',
    '3.7',
    '3.6',
)

perlVersions = (
    '5.24.0',
    '5.22.0',
    '5.20.0',
)

qtVersions = (
    '5.7.0',
    '5.6.0',
    '5.5.0',
    '5.4.0',
    '5.3.0',
    '5.2.0',
)

config = {
    'matrix': {
        'include': []
    }
}

for (clangVersion, qtVersion, perlVersion) in product(clangVersions, qtVersions, perlVersions):
    d = {
        'env': 'CLANG_VERSION={0} QT_VERSION={1} PERL_VERSION={2}'.format(
            clangVersion, qtVersion, perlVersion
        ),
        'addons': {
            'apt': {
                'sources': [
                    'ubuntu-toolchain-r-test',
                    'llvm-toolchain-precise-{0}'.format(clangVersion),
                    'george-edison55-precise-backports',
                ],
                'packages': [
                    'clang-{0}'.format(clangVersion),
                    'libclang-{0}-dev'.format(clangVersion),
                    'llvm-{0}-dev'.format(clangVersion),
                    'cmake',
                    'cmake-data',
                    'libgtest-dev',
                    'libedit-dev',
                ]
            }
        }
    }
    config['matrix']['include'].append(d)

yaml.dump(config, sys.stdout, default_flow_style=False)
print(len(config['matrix']['include']))
