#!/usr/bin/env python

from distutils.core import setup

setup(name='vurmpipeline',
      version='1.0.0',
      description='VU Reading Machine Pipeline',
      author='Sophie Arnoult',
      author_email='s.i.arnoult@vu.nl',
      url='https://github.com/cltl/vu-rm-pip3',
      packages=['wrapper'],
      install_requires=['KafNafParserPy','lxml','PyYAML','requests','six']
     )
