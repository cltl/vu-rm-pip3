"""
Defines a module with input and output layers, and a name pointing to a shell script for running that module
"""

import subprocess, sys
import logging
from subprocess import Popen, PIPE, STDOUT
logger = logging.getLogger(__name__)


class Module:
    def __init__(self, input_layers, output_layers, name):
        self._input_layers = input_layers
        self._output_layers = output_layers
        self.name = name
        self.cmd = "./scripts/bin/" + name

    @property
    def input_layers(self):
        return self._input_layers

    @input_layers.setter
    def input_layers(self, val):
        self._input_layers = val

    @property
    def output_layers(self):
        return self._output_layers

    @output_layers.setter
    def output_layers(self, val):
        self._output_layers = val

    def run(self, input_file, output_dir, file_pfx):
        output_file = open(output_dir + file_pfx + "." + self.name, 'w')
        try:
            p = Popen([self.cmd], stdin=input_file, stdout=output_file)
            return p.communicate()
        except Exception as e:
            logger.error(e)
            raise 
        finally:
            input_file.close()
        


ixa_tok = Module([], ["Token"], "tok")

alpino_naf = Module(["Token"], ["Term", "Dep", "Const"], "alpino")

ixa_nerc = Module(["Token", "Term"], ["Entity"], "ixa-nerc")

ixa_ned = Module(["Entity"], ["Entity"], "ixa-ned")

ixa_time = Module(["Token", "Term"], ["TimeExp"], "time")

svm_wsd = Module(["Token", "Term"], ["Term"], "svm-wsd")

sonar_srl = Module(["Term", "Const", "Dep"], ["SRL"], "srl")

pm_tagger = Module(["Term"], ["Term"], "pm-tag")

nom_event = Module(["Token", "Term"], ["SRL"], "nom-ev")

nom_pred = Module(["Term", "Dep", "SRL"], ["SRL"], "np-srl")

f_net = Module(["Term", "SRL"], ["SRL"], "fnet")

coref = Module(["SRL"], ["Coref"], "coref") 

opin = Module(["Token", "Term", "Const", "Dep", "Entity"], ["Opin"], "opin")

fact = Module(["Term"], ["Fact"], "fact")

knownModules = [ixa_tok, alpino_naf, ixa_nerc, ixa_ned, ixa_time, svm_wsd, sonar_srl, pm_tagger, nom_event, nom_pred, f_net, coref, opin, fact]

