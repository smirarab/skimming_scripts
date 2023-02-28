#!/usr/bin/env Rscript
args = commandArgs(trailingOnly=TRUE)
print(args)
m=as.matrix(read.csv(args[1],sep='\t',row.names=1)); 
pdf(paste('fig',args[2],'.pdf',sep=''),width=12,height=10);
  plot(hclust(as.dist(m))); 
  try(require(gplots))
  try(heatmap.2(m, scale = "none", col = heat.colors(100,rev=T), trace = "none",margin=c(16,18)))
  heatmap(m, scale = 'none', col = heat.colors(100,rev=T));
dev.off(); 
write.table(file=paste('dist',args[2],'-reformatted.txt',sep=''),format(data.frame(name = row.names(m), m),digits=3),qu=F,sep='\t',row.names = FALSE);
