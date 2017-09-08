#小区对1月的匹配#
a=read.table("F://小区.txt")
b=read.table("F://地址.txt")
a1=as.matrix(a)
b1=as.matrix(b)
b2=t(b1)

res=data.frame()
resm=as.matrix(res)
for (i in 1:4034){
  m <-regexpr(a1[i], b1)
  for (j in 1:36691){
    if (m[j]>=0){
  resm[j]=a1[i]
    }
    
  }
}
reamm=as.matrix(as.(resm))
c=as.data.frame()
for (j in 1:36991){
  if (resm[j] ){
    resm[j]=0
  }
}
write.csv(reamm,file="F://匹配1.csv")
reamm
warning()
data.frame(a1[9])


#小区对1月的匹配2#
c=read.table("F://抓取小区2.txt")
d=read.table("F://地址.txt")
c1=as.matrix(c)
d1=as.matrix(d)


res=data.frame()
resm=as.matrix(res)

reamm=as.matrix(as.(resm))
for (i in 1:1517){
  m <-regexpr(c1[i], d1)
  for (j in 1:36691){
    if (m[j]>=0){
      resm[j]=c1[i]
    }
    
  }
}
reamm=as.matrix(resm)
write.csv(reamm,file="F://匹配2.csv")

#小区对2月匹配#
c=read.table("F://小区.txt")
d=read.table("F://地址.txt")
c1=as.matrix(c)
d1=as.matrix(d)


res=data.frame()
resm=as.matrix(res)


for (i in 1:5551){
  m <-regexpr(c1[i], d1)
  for (j in 1:19719){
    if (m[j]>=0){
      resm[j]=c1[i]
    }
    
  }
}
reamm=as.matrix(resm)
write.csv(reamm,file="F://匹配3.csv")
