## Python functions for snakemake pipeline ##

def isEmpty(path) :
	subDirs = next(os.walk(path))[1]
	empty = ['1' for dir in subDirs if len(os.listdir(path+dir))==0]
	if len(empty)==len(subDirs) :
		return(True)
	else :
		return(False)


def isFormated (file) :
	hasDash = open(file, 'r')
	DashCount = hasDash.read().count('-')
	if DashCount==0 :
		return(True)
	else :
		return(False)

# def checkFiles (filePath) :
# 	if os.path.dirname(filePath).find('ko_pathways')!=(-1) :
# 		if filePath.endswith('tmp_all_genomes_ghostkoala_annotation.txt') :
# 			err1 = ('Please rename file : %s as "tmp_all_genomes_ghostkoala_annotation.txt" ' % )
# 	elif os.path.dirname(filePath).find('macsyfinder_output')!=(-1) :
# 		if 

# 	if Path(filePath).is_file() :
# 		print('file %s: exists' % filePath)
# 	else :
