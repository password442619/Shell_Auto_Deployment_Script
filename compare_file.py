#!/usr/bin/env python
import os,sys,difflib

AFILE = []
BFILE = []
COMMON = []

def getPrettyTime(state):
	return time.strftime('%Y-%m-%d %H-%M-%S', time.localtime(state.st_time))

##获得文件大小
#def getpathsize():
#	size = 0
#	for root,dirs,files in os.walk(dir):
#		for file in files:
#			path = os.path.join(root,file)
#			size = os.path.getsize(path)
#	return size
#
def dirCompare(apath, bpath):
	afiles = []
	bfiles = []
	for root,dirs,files in os.walk(apath):
		for f in files:
			afiles.append(root + "/" + f)

	for root,dirs,files in os.walk(bpath):
		for f in files:
			bfiles.append(root + "/" +f)
	apathlen = len(apath)
	aafiles = []
	for f in afiles:
		aafiles.append(f[apathlen:])
	
	bpathlen = len(bpath)
	bbfiles = []
	for f in bfiles:
		bbfiles.append(f[bpathlen:])
	afile = aafiles
	bfile = bbfiles
	setA = set(afiles)
	setB = set(bfiles)
	commonfiles = setA & setB

	for f in sorted(commonfiles):
		sA = os.path.getsize(apath + "/" + f)
		sB = os.path.getsize(bpath + "/" + f)
		if sA == sB:
			saf = []
			sbf = []
			sAfile = open(apath + "/" + f)
			iter_f = iter(sAfile)
			for line in iter_f:
				saf.append(line)
			sAfile.close()
			sBfile = open(bpath + "/" + f)
			iter_fb = iter(sBfile)
			for line in iter_fb:
				sbf.append(line)
			sBfile.close()
			saf1 = sorted(saf)
			sbf1 = sorted(sbf)
			if(len(saf1) != len(sbf1)):
				with open(os.getcwd()+'/comment_diff.txt','a') as fp:
					print(os.getcwd())
					fp.write(apath + "/" + f + "lines size not equal"+bpath+"/"+f+'\n')
			else:
				for i in range(len(saf1)):
					if(saf1[i] != sbf1[i]):
						print('into commont')
						with open(os.getcwd()+'/comment_diff.txt','a') as fp1:
							fp1.write(apath + "/" + f+ "content not equal"+ bpath+ "/" + f + '\n')
							break
		else:
			with open(os.getcwd()+'/diff.txt','a') as di:
				di.wirte("File Name=%s EEresource file size:%d != SVN file size:%d"%(f,sA,sB))
	onlyFiles = setA ^ setB
	aonlyFiles = []
	bonlyFiles = []
	for of in onlyFiles:
		if of in afiles:
			aonlyFiles.append(of)
		elif of in bfiles:
			bonlyFiles.append(of)

	for of in sorted(aonlyFiles):
		with open(os.getcwd()+'/EEonly.txt','a') as ee:
			ee.write(of+'\n')

	for of in sorted(bonlyFiles):
		with open(os.getcwd()+'/svnonly.txt','a') as svn:
			svn.write(of+'\n')

if __name__ == '__main__':
	FolderEE = '/mnt/code'
	FolderSVN = '/mnt/code1'
	dirCompare(FolderEE,FolderSVN)
	print("done!")
