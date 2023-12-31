#!/usr/bin/env python3

import tempfile
from asyncio.subprocess import DEVNULL
from os import path
from re import S
import sys
import os.path
from pathlib import Path
import argparse
import subprocess
from subprocess import Popen, PIPE
import platform
import argparse

CRED = '\33[31m'
CGREEN = '\33[32m'
RESET = "\033[0;0m"
CBOLD = '\33[1m'

numOfTests=0
numOfFailedTests=0
verbose=False
ciRun=False


def xprint(str, color = ''):
    global ciRun
    if (not ciRun):
        print(color, end='')
    print(str, end='')
    if (not ciRun):
        print(RESET)
    else:
        print('') # endline


def computePath(path, *paths):
    return os.path.normpath(os.path.join(path, *paths))


def compareFilesLineByLine(marker, testFile, actualFile, expectedFile):
    global numOfFailedTests
    with open(expectedFile) as expected, open(actualFile) as actual:
        expectedLines = expected.readlines()
        actualLines = actual.readlines()
        differs = len(expectedLines) != len(actualLines)
        if differs == False:
            i = 0
            while i < len(expectedLines):
                e = expectedLines[i].rstrip()
                a = actualLines[i].rstrip()
                i += 1
                if e != a:
                    differs = True
                    break

        if differs == True:
            xprint("")
            xprint(f"\nFAIL: {testFile}", CBOLD + CRED)
            xprint("--Actual------------------", CBOLD + CRED)
            xprint("".join(actualLines))
            xprint("--Expected----------------", CBOLD + CRED)
            xprint("".join(expectedLines))
            xprint("--------------------------", CBOLD + CRED)
            xprint("")
            numOfFailedTests += 1
            return False

    return True


def updateExpectedFromActualIfNeed(marker, actualFile, expectedFile):
    if (not path.exists(expectedFile)):
        xprint(f"  info: no {marker} expected file, create it")
        result = open(actualFile).read()
        open(expectedFile, 'w+').write(result)


def runTestGeneric(compiler, workingDir, dirname, name, kind, suffix, extraargs, stdoutFile):
    global numOfFailedTests
    global verbose
    global have_errors
    testFilePath = computePath(dirname, name + '.nut')

    if (not path.exists(testFilePath)):
        testFilePath = computePath(dirname, name + '.nut.txt')

    expectedResultFilePath = computePath(dirname, name + suffix)
    outputDir = computePath(workingDir, dirname)

    if (not path.exists(outputDir)):
        os.makedirs(outputDir)

    actualResultFilePath = computePath(workingDir, expectedResultFilePath)

    if path.exists(actualResultFilePath):
        os.remove(actualResultFilePath)

    compilationCommand = [compiler, "-optCH"]
    compilationCommand += extraargs

    if stdoutFile:
        outredirect = open(actualResultFilePath, 'w+')
    else:
        outredirect = subprocess.PIPE
        compilationCommand += [actualResultFilePath]

    compilationCommand += [testFilePath]

    if verbose:
        xprint(compilationCommand)

    proc = Popen(compilationCommand, stdout=outredirect, stderr=subprocess.PIPE)

    outs = None
    errs = None
    try:
        outs, errs = proc.communicate(timeout=10)
    except subprocess.TimeoutExpired:
        proc.kill()
        outs, errs = proc.communicate()
        xprint("\nTIMEOUT: sq froze on test: {0}\n".format(testFilePath), CBOLD + CRED)
        numOfFailedTests = numOfFailedTests + 1
        return

    if proc.returncode != 0:
        xprint("\nCRASH: {0}".format(testFilePath), CBOLD + CRED)
        numOfFailedTests = numOfFailedTests + 1
        if outs != None:
            xprint("--stdout------------------", CBOLD + CRED)
            xprint(outs.decode('utf-8'))
        if errs != None:
            xprint("--stderr------------------", CBOLD + CRED)
            xprint(errs.decode('utf-8'))
        if errs != None or outs != None:
            xprint("--------------------------", CBOLD + CRED)
            xprint("")
    else:
        testOk = True
        if (path.exists(expectedResultFilePath)):
            testOk = compareFilesLineByLine(kind, testFilePath, actualResultFilePath, expectedResultFilePath)

        if (testOk):
            xprint(f"PASSED: {testFilePath}", CBOLD + CGREEN)

        updateExpectedFromActualIfNeed(kind, actualResultFilePath, expectedResultFilePath)


def runDiagTest(compiler, workingDir, dirname, name):
    runTestGeneric(compiler, workingDir, dirname, name, "Diagnostics", '.diag.txt', ["-diag-file"], False)

def runSATest(compiler, workingDir, dirname, name):
    runTestGeneric(compiler, workingDir, dirname, name, "Static Analyser", '.diag.txt', ["-sa", "-diag-file"], False)

def runExecuteTest(compiler, workingDir, dirname, name):
    runTestGeneric(compiler, workingDir, dirname, name, "Exec", '.out', [], True)


def runASTTest(compiler, workingDir, dirname, name):
    runTestGeneric(compiler, workingDir, dirname, name, "AST", '.opt.txt', ["-ast-dump"], False)


def runTestForData(filePath, compiler, workingDir, testMode):
    global numOfFailedTests
    global numOfTests

    numOfTests = numOfTests + 1

    # print(f"processing {filePath}")
    basename = os.path.basename(filePath)
    dirname = os.path.dirname(filePath)
    index_of_dot = basename.index('.')
    name = basename[:index_of_dot]
    suffix = basename[index_of_dot:]
    # print(f"dirname: {dirname}, baseName: {basename}, name: {name}, suffix: {suffix}")
    if suffix == ".nut" or suffix == ".nut.txt":
        if testMode == 'ast':
            runASTTest(compiler, workingDir, dirname, name)
        elif testMode == 'diag':
            runDiagTest(compiler, workingDir, dirname, name)
        elif testMode == 'exec':
            runExecuteTest(compiler, workingDir, dirname, name)
        elif testMode == 'sa':
            runSATest(compiler, workingDir, dirname, name)
        else:
            xprint(f"Unknown test mode {testMode}")


def walkDirectory(path, indent, block):
    for file in path.iterdir():
        # print('\t' * indent + f"Walk path {file}")
        if file.is_dir():
            walkDirectory(file, indent + 1, block)
        else:
            block(file)

def checkCompiler(compiler):
    try:
        compProc = Popen([compiler, '-v'], stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
        compProc.communicate()
        if compProc.returncode != 0:
            xprint('FAIL: {0} is not an sq compiler'.format(compiler))
            exit(1)
    except:
        xprint('FAIL: {0} is not an sq compiler'.format(compiler))
        exit(1)


def main():
    global numOfFailedTests
    global verbose, ciRun
    default_sq = computePath('build', 'bin', 'Debug', 'sq.exe' if platform.system() == 'Windows' else 'sq')

    parser = argparse.ArgumentParser(description='quirrel test runner')
    parser.add_argument('-sq', '--squirrel', action="store", type=str, default = default_sq, help = "Path to Quirrel compiler")
    parser.add_argument('-wd', '--working-dir', action="store", type=str, default = tempfile.TemporaryDirectory().name, help = "Directory to store tests data like ast dumps, diganotics dumps and so on")
    parser.add_argument('-v', '--verbose', default = False, action="store_true", help = "Extra output like CLI commands")
    parser.add_argument('-ci', '--continious-integration', default = False, action="store_true", help = "Signals that script is being run under CI")

    args = parser.parse_args()

    compiler = args.squirrel
    workingDir = args.working_dir
    verbose = args.verbose
    ciRun = args.continious_integration

    checkCompiler(compiler)

    walkDirectory(Path(computePath('testData', 'exec')), 0, lambda a: runTestForData(a, compiler, workingDir, 'exec'))
    walkDirectory(Path(computePath('testData', 'diagnostics')), 0, lambda a: runTestForData(a, compiler, workingDir, 'diag'))
    walkDirectory(Path(computePath('testData', 'ast')), 0, lambda a: runTestForData(a, compiler, workingDir, 'ast'))
    walkDirectory(Path(computePath('testData', 'static_analyser')), 0, lambda a: runTestForData(a, compiler, workingDir, 'sa'))

    if numOfFailedTests:
        xprint(f"Failed tests: {numOfFailedTests}", CBOLD + CRED)
    else:
        xprint(f"All tests passed", CBOLD + CGREEN)

    exit (1 if numOfFailedTests > 0 else 0)



if __name__ == "__main__":
   main()

