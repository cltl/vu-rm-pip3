import subprocess, sys, logging
import argparse
from subprocess import Popen, PIPE, STDOUT

logger = logging.getLogger(__name__)
#logging.basicConfig(format='%(name)s - %(levelname)s - %(message)s',
logging.basicConfig(format='%(message)s',
                filename='pipeline.log',
                filemode='w',
                level=logging.INFO)


def find_error(stderr_iterator):
    found_error = False
    for line in stderr_iterator:
        line = line.decode().strip()
        if 'Exception' in line or 'Error' in line or 'error' in line:
            logger.error(line)
            found_error = True
        else:
            logger.info(line)
    return found_error


def is_valid(modules, available):
    if modules:
        m, *ms = modules
        if m.input_layers:
            for layer in m.input_layers:
                if layer not in available:
                    return False
        available.update(m.output_layers)
        return is_valid(ms, available)
    else:
        return True


class Pipeline:
    def __init__(self, modules):
        self.modules = modules

    def is_valid(self):
        return is_valid(self.modules, set())

    def run(self, input_file, output_dir, file_pfx):
        last_module = None
        for m in self.modules:
            last_module = m
            logger.info('------------- ' + m.name + ' --------------')
            output_file = open(output_dir + file_pfx + "." + m.name, 'w')
            p = Popen([m.cmd], stdin=input_file, stdout=output_file, stderr=PIPE)
            if find_error(iter(p.stderr.readline, b'')):
                logger.info("module " + m.name + " returned an error; exiting now")
            out, err = p.communicate()
            input_file.close()
            output_file.close()
            input_file = open(output_dir + file_pfx + '.' + m.name, 'r')
        
        out = input_file.read()
        input_file.close()
        return out

    def run_pipeline_from_file(self, file_name):
        infile = open(file_name, 'r')
        return self.run_pipeline(infile)
 
    def run_pipeline(self, infile):
        m0, *m1seq = self.modules
        p0 = Popen([m0.cmd], stdin=infile, stdout=PIPE, stderr=PIPE)
        logger.info('------------- ' + m0.name + ' --------------')
        
        # looks for mention of error in stderr when running module
        if find_error(iter(p0.stderr.readline, b'')):
            logger.info("module " + m0.name + " returned an error; exiting now")
            output = p0.communicate()[0]
            return output.decode()

        while m1seq:
            m1, *mseq = m1seq
            # pipes output of previous module
            p1 = Popen([m1.cmd], stdin=p0.stdout, stdout=PIPE, stderr=PIPE)
            logger.info('\n------------- ' + m1.name + ' --------------')
            p0.stdout.close()
            
            if find_error(iter(p1.stderr.readline, b'')):
                logger.info("module " + m1.name + " returned an error; exiting now")
                output = p1.communicate()[0]
                return output.decode()

            p0 = p1
            m1seq = mseq

        output = p0.communicate()[0]
        return output.decode()


if __name__ == "__main__":
    import sys
    import module
    import sys
    import io
    from module import ixa_tok, ixa_nerc, ixa_ned, alpino_naf, svm_wsd, opin, fact, f_net, pm_tagger, ixa_time, sonar_srl, nom_event, nom_pred, coref

    parser = argparse.ArgumentParser(description='Morphosyntactic parser based on Alpino')
    parser.add_argument('-d', '--out_dir', dest='output_dir', type=str, help='output directory for intermediary files')
    parser.add_argument('-f', '--file_pfx', dest='file_pfx', type=str, help='prefix of intermediary files')
    args = parser.parse_args()


    output_dir = args.output_dir
    file_pfx = args.file_pfx
    if output_dir and not file_pfx:
        file_pfx = 'sys'
    if not output_dir and file_pfx:
        output_dir = './'

    components = [ixa_tok, alpino_naf, ixa_nerc, svm_wsd, pm_tagger, sonar_srl, f_net, nom_event, nom_pred, coref, opin, fact, ixa_time]
    pipeline = Pipeline(components)
    input_file = sys.stdin
    if output_dir and file_pfx:
        out = pipeline.run(input_file, output_dir, file_pfx)
    else:
        out = pipeline.run_pipeline(input_file)
       
    print(out)
