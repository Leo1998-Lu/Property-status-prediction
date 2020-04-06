library(readr)
april<- read_csv("ny_april_10009.csv")
head(april,10)
#check the data
summary(april)
nrow(april)
str(april)
names(april)

#Average price of different PropertyID in April
ID_price<-aggregate(april$Price,by=list(april$PropertyID),FUN=mean);
n.ID<-nrow(ID_price);n.ID#total of 1003 IDs
t.test(april$PropertyID)
#summary statistics & graph of Price
par(mfrow=c(2,1))
hist(april$Price,breaks =100,xlab="Price",main="Histogram of Price")
mean(april$Price)
text(1500, 3000, "Average Price :$179",cex=1.5)
plot(density(april$Price),main="Price density distribution")
summary(april$Price)
sd(april$Price)
length(levels(factor(april$Price)))
##Exploring the relationship between Status and Price
library(ggplot2)
#creating a sub-dataframe with no extreme values / less than 500
norm.price<-subset(april,Price<500,select=c(Status:Price) )
ggplot(norm.price, aes(y = Price, x = Status ,fill = Status))+
  geom_violin()+theme_bw()+labs(x = 'Status', y = 'Price')
factor(april$Status)
A<-subset(april,Status == "A",select=c(Status:Price) )
summary(A)
B<-subset(april,Status == "B",select=c(Status:Price) )
summary(B)
R<-subset(april,Status == "R",select=c(Status:Price) )
summary(R)
par(mfrow=c(3,1))
hist(A$Price,xlab = "Price of Status: A",main="Histogram of Price in Status A")
text(1500,6000,"Average Price: $184")
hist(B$Price,xlab = "Price of Status: B",main="Histogram of Price in Status B")
text(1000,2000,"Average Price: $180")
hist(R$Price,xlab = "Price of Status: R",main="Histogram of Price in Status R")
text(1500,2000,"Average Price: $168")
##Exploring the relationship between time and house prices
aggregate(april$Price,by=list(april$Date),FUN=mean)
date.price <-
  april %>%
  group_by(Date)%>%           #Classified by time
  summarise(MeanPrice = mean(Price)) #Statistics average price in April
t<-ts(1:30,frequency = 7)
plot.ts(t,date.price$MeanPrice,ylab="Average Price of April",xlab="Time Series")



library(maps)
library(mapdata)
map('state',panel.first=grid())
axis(1,lwd=0)
axis(2,lwd=0)
axis(3,lwd=0)
axis(4,lwd=0)
box()

library(readr)
property <- read_csv("ny_property_10009.csv")
names(property)
View(property)
loc<-property[,c(46,47)];loc
Type<-property[,c(5,6)];Type
loc_type<-as.data.frame(cbind(Type,loc));loc_type

library(ggplot2)
names(loc_type)
#Explore the spatial distribution of Listing Type and Property Type
ggplot(loc_type, aes(x = Latitude, y = Longitude,shape=`Listing Type`,col=`Property Type`)) +
  geom_point() 

ggplot(loc_type, aes(x = Latitude, y = Longitude,col=`Listing Type`)) +
  geom_point() +
  stat_density2d(aes(alpha = stat(density)), geom = "raster", contour = FALSE,inherit.aes = TRUE)


#========2019/11/20
library(readr)
library(dplyr)
april<- read_csv("ny_april_10009.csv")
property <- read_csv("ny_property_10009.csv")
str(april)
str(property)
names(april)
summary(april)
head(april)
x<-subset(april,select=c(PropertyID:Price) )

x$Status<-factor(x$Status,levels = c("A","B","R"),labels = c("available","block","reserved"))
summary(x)


#1.plot histogram for number of days blocked throughout the time period
k=nrow(x)/30
sum(ifelse(x$Status=="block",1,0))/(30*k)#Average ratio of all property in blocks type days in April


aggregate(as.numeric(x$Status=="block"),by=list(x$PropertyID),FUN=sum)

ID_blcok<-
  x %>%
  filter(Status=="block")%>%
  group_by(PropertyID)%>%
  summarise(Count = n())
ID_blcok
hist(ID_blcok$Count,xlab = "The number of days of block type of per PropertyID in April",main="Histogram plot")

#2.Calculate the average number of days between two blocking days across listing
X<-x[,3]
k=nrow(X)/30 #total number of propertyID
X<-as.numeric(X$Status)
s=c()
for(i in 1:length(X)){
  s[i]=abs(2-X[i])
}
s #0即为block状态 1未非block状态     #计算连续为1的次数及长度


i=1:k
v=((i-1)*30+1)
head(v)
e=i*30
head(e)
f=matrix(NA,k,30)

for(i in 1:k){
  f[i,]<-t(s[v[i]:e[i]])
}#将每个listing拆分出来 每行1个listing
f
head(f)

m=matrix(0,k,1) 
for(j in 1:k){
  for(i in 1:29){
    if((f[j,i]+f[j,i+1])>=1) m[j,]=m[j,]+1
  }
}#前一位数与后一位数的和大于1说明这是一段连续为1的状态（即非block状态)
m #连续为1的总共长度(多出L个)
# m[1]
# head(s,30)
l=matrix(0,k,1) 
for(j in 1:k){
  for(i in 1:29){
    if((f[j,i]-f[j,i+1])!=0) l[j,]=l[j,]+1
  }
}#前一位数与后一位数的和不等于0说明这是一个0-1的转变
l#连续为1的次数
l[1]
L<-ceiling(l/2) 
result<-(m[1:k]-L[1:k])/L[1:k]
result<-result[result!=Inf]
result<-result[!is.na(result)]
sum(result/k) #每家店两个block天数间隔平均数




#3.Analyze blocking pattern
sumblock<-aggregate(as.numeric(x$Status=="block"),by=list(x$Date),FUN=sum)#Count the total number of block types per day in April
sumblock
y<-x %>%
  filter(Status=="block")%>%
  group_by(Date)%>%           #Classified by time
  summarise(Total_block_per_day = n()) #Count the total number of block types per day in April
y
library(ggplot2)
ggplot(y,aes(x=Total_block_per_day))+geom_histogram(bins=10,position = "stack")+theme_bw()




t<-ts(1:30,frequency = 7)
plot(t,y$Total_block_per_day,ylab="Total number of block type",xlab="Time : Start From April 1, 2015")#pic.3 It can be seen from the figure that it seems that it is more possible to have block type on Wednesday and Thursday every week.


#Other analysis can you come up with to futher understanding on the blocking behavior
#随机游程检验 假设检验： H0：block状态是随机的  H1：block状态不随机
library(tseries)
runs.test(factor(f))#违反随机性******** p-value < 2.2e-16 说明block状态跟日期有一定关系
plot(x=1:30,y=y$Total_block_per_day,type="h")
block_price<-x %>%
  filter(Status=="block")%>%
  group_by(Price)%>%           #Classified by time
  summarise(Total_block_number = n()) #Count the total number of block types per day in April

plot(density(block_price$Price),main="density of block type price")

no_block_price<-x %>%
  filter(Status!="block")%>%
  group_by(Price)%>%           #Classified by time
  summarise(Total_block_number = n()) #Count the total number of block types per day in April
lines(density(no_block_price$Price),col=2)

#block状态的price与非block状态的price的分布比较接近，但高价的property有更多是block状态

#5.Are there correlations between blocking behaviors for adjacent apartment?
names(property)
names(property)[2]<-"PropertyID"
colnames(property)
newdata<-merge(property,x,by="PropertyID")
newdata<-newdata[,c("PropertyID","Status","Latitude","Longitude")]
head(newdata)

library(ggplot2)
ggplot(newdata, aes(x = Latitude, y = Longitude,shape=Status,col=Status)) +
  geom_point() +
  stat_density2d(aes(alpha = stat(density)), geom = "raster", contour = FALSE,inherit.aes = TRUE)

ggplot(newdata, aes(x = Latitude, y = Longitude,col=Status=="block")) +
  geom_point()+theme_light()+
  stat_density2d(aes(alpha = stat(density)), geom = "raster", contour = FALSE,inherit.aes = TRUE)
#看起来block状态是呈一个无规则的随机分布
newdata$Status<-as.numeric(newdata$Status)
cor(newdata)#不同状态与位置相关性很小
block_loc<-cbind(ifelse(newdata$Status==2,1,0),newdata$Latitude,newdata$Longitude)
colnames(block_loc)<-c("Is Block?","Lat","Lon")
cor(block_loc)#block状态与位置相关性确实很小


# Markov
pa<-sum(x$Status=="available")/nrow(x)
pb<-sum(x$Status=="block")/nrow(x)
pc<-sum(x$Status=="reserved")/nrow(x)
c(pa,pb,pc)
length(x$Status)
#trainsition matrix for the probability of switching from one state to another
#A-R-B-A-B-R 状态空间S={A,B,R}
#A-R：1-3   #A-B： 1-2   #A-A:1-1
#B-R: 2-3   #B-B:  2-2   #B-A:2-1
#R-R:=3-3    #R-B:  3-2  #R-A=3-1
#==A
c1=0
for(i in 1:length(X)){
  if(X[i]==1 & X[i+1]==3) c1=c1+1
}
c1  #A-R：1-3

c2=0
for(i in 1:length(X)){
  if(X[i]==1 & X[i+1]==2) c2=c2+1
}
c2  #A-B： 1-2

c3=0
for(i in 1:length(X)){
  if(X[i]==1 & X[i+1]==1) c3=c3+1
}
c3 ##A-A:  1-1
P1<-c(c1,c2,c3)/(c1+c2+c3);P1  #probability of switching from  state "available"


#==B
c4=0
for(i in 1:length(X)){
  if(X[i]==2 & X[i+1]==3) c4=c4+1
}
c4  #B-R: 2-3

c5=0
for(i in 1:length(X)){
  if(X[i]==2 & X[i+1]==2) c5=c5+1
}
c5  #B-B:  2-2  

c6=0
for(i in 1:length(X)){
  if(X[i]==2 & X[i+1]==1) c6=c6+1
}
c6  #B-A: 2-1
P2<-c(c4,c5,c6)/(c4+c5+c6);P2  #probability of switching from  state "block"

#==R
c7=0
for(i in 1:length(X)){
  if(X[i]==3 & X[i+1]==3) c7=c7+1
}
c7  #R-R: 3-3    

c8=0
for(i in 1:length(X)){
  if(X[i]==1 & X[i+1]==2) c8=c8+1
}
c8   #R-B:3-2  

c9=0
for(i in 1:length(X)){
  if(X[i]==3 & X[i+1]==1) c9=c9+1
}
c9  #R-A: 3-1
P3<-c(c7,c8,c9)/(c7+c8+c9);P3  #probability of switching from  state "available"


trainsition_matrix<-matrix(t(c(P1,P2,P3)),3,3)
colnames(trainsition_matrix)<-c("A","B","R")
rownames(trainsition_matrix)<-c("R","B","A")
trainsition_matrix

P<-matrix(t(c(P1,P2,P3)),3,3) #一步转移矩阵
m=length(X) #样本函数的长度
statu=3 #状态空间的个数
S=3 #MC初始状态
o<-c(1,2,3) #状态空间 从1开始计数
N=rep(0,statu);

for(i in 1:(m-1)){
  for(j in 1:statu){
    if(S[i]==j){S[i+1]=sample(o,1,p=P[j,],replace=TRUE);N[j]=N[j]+1;}
  }
}
S #样本函数
N/m #状态出现的频率(一次模拟结果) 显然接近平稳分布
c(pa,pb,pc)#原样本的状态出现频率

N1=rep(0,statu);
for(i in 101:m){
  for(j in 1:statu){
    if(S[i]==j) N1[j]=N1[j]+1
  }
}
N1/(m-100) #MC自时刻100后各个状态出现的频率


#aligned with the rental revenues collected by region
factor(alldata$Neighborhood)#two type
par(mfrow=c(2,1))
sum(alldata$Neighborhood=="Stuyvesant Town")
Stuyvesant_Town<-alldata[alldata$Neighborhood=="Stuyvesant Town","Price"]
Stuyvesant_Town
mean(Stuyvesant_Town)
hist(Stuyvesant_Town,main="Histogram of the Rental Revenues in Stuyvesant Town")

sum(alldata$Neighborhood=="East Village")
East_Village<-alldata[alldata$Neighborhood=="East Village","Price"]
mean(East_Village)
hist(East_Village,main="Histogram of the Rental Revenues in East Village")


#####2019/12/6=====
library(gridExtra)
library(ggplot2)
names(property)
names(property)[2]<-"PropertyID"
colnames(property)
newdata<-merge(property,april,by="PropertyID")
str(newdata)
summary(newdata$Price)
newdata$Status
factor(newdata$Neighborhood)#two type
par(mfrow=c(2,1))
sum(newdata$Neighborhood=="Stuyvesant Town")
Stuyvesant_Town<-newdata[newdata$Neighborhood=="Stuyvesant Town",c("Price","Status","Annual Revenue LTM","price_norm")]
Stuyvesant_Town

p1<-ggplot(Stuyvesant_Town,aes(Price,fill=Status))+geom_histogram()+
  labs(title="Histogram of the Rental Revenues in Stuyvesant Town")+theme_minimal()
p1.1<-p2.1<-ggplot(Stuyvesant_Town,aes(x=`Annual Revenue LTM`,fill=Status))+geom_histogram()+
  labs(title="Histogram of the Annual Revenues in Stuyvesant_Town LTM")+theme_minimal()
grid.arrange(p1,p1.1,nrow=2)

sum(newdata$Neighborhood=="East Village")
East_Village<-newdata[newdata$Neighborhood=="East Village",c("Price","Status","Annual Revenue LTM","price_norm")]

p2<-ggplot(East_Village,aes(Price,fill=Status))+geom_histogram()+
  labs(title="Histogram of the Rental Revenues in East_Village")+theme_minimal()


p2.1<-ggplot(East_Village,aes(x=`Annual Revenue LTM`,fill=Status))+geom_histogram()+
  labs(title="Histogram of the Annual Revenues in East_Village LTM")+theme_minimal()

grid.arrange(p2,p2.1,nrow=2)


#correlogram
Stuyvesant_Town$Status<-as.numeric(factor(Stuyvesant_Town$Status))#A:1 B:2 R:3
East_Village$Status<-as.numeric(factor(East_Village$Status))

cor(Stuyvesant_Town$Price,Stuyvesant_Town$`Annual Revenue LTM`)
cor(East_Village$Price,East_Village$`Annual Revenue LTM`)

cor(Stuyvesant_Town)
cor(East_Village)
summary(Stuyvesant_Town)
summary(East_Village)
#model
fit.Stuyvesant_Town<-lm(Status~.,data=Stuyvesant_Town)
summary(fit.Stuyvesant_Town)

fit.East_Village_Town<-lm(Status~.,data=East_Village)
summary(fit.East_Village_Town)


#randomforest
library(randomForest)
names(Stuyvesant_Town)[3]<-"Annual.Revenue.LTM"
Stuyvesant_Town$Status<-as.factor(Stuyvesant_Town$Status)
forest.Stuyvesant_Town<-randomForest(Status~.,data=Stuyvesant_Town)


names(East_Village)[3]<-"Annual.Revenue.LTM"
East_Village$Status<-as.factor(East_Village$Status)
forest.East_Village<-randomForest(Status~.,data=East_Village)

pred<-predict(forest.Stuyvesant_Town,Stuyvesant_Town)
sum(diag(table(pred,Stuyvesant_Town$Status)))/sum(table(pred,Stuyvesant_Town$Status))

##GLM  #A:1 B:2 R:3  1:Block 0:Unblock
East_Village$Status<-ifelse(East_Village$Status==2,1,0)
ft.logit<-glm(Status~.,data=East_Village,family = binomial)
summary(ft.logit)
Pd<-predict(ft.logit,East_Village,type="response")
PD<-ifelse(Pd>0.5,1,0)

ltabpd=table(East_Village$Status,PD,dnn=c("实际样本","预测结果"))
ltabpd
sum(diag(prop.table(ltabpd)))#0.7

#outsample
ind<-sample(nrow(East_Village),0.7*nrow(East_Village))
insample<-East_Village[ind,]
outsample<-East_Village[-ind,]

in.logit<-glm(Status~.,data=insample,family = binomial)
summary(in.logit)

outPd<-predict(in.logit,outsample,type="response")
outPD<-ifelse(outPd>0.5,1,0)

outltabpd=table(outsample$Status,outPD,dnn=c("实际样本","预测结果"))
outltabpd
sum(diag(prop.table(outltabpd)))#0.7

#MAPE
resid <- East_Village$Status-PD
A_t<-East_Village$Status
A_t[which(A_t == 0)] <- mean(A_t)
mean(abs(resid)/A_t)

resid <- outsample$Status-outPD
A_t<-outsample$Status
A_t[which(A_t == 0)] <- mean(A_t)
mean(abs(resid)/A_t)

mean(resid)
#######2019/12/23#########
library(gridExtra)
library(ggplot2)
library(readr)
april<- read_csv("ny_april_10009.csv")
property <- read_csv("ny_property_10009.csv")
names(property)
names(property)[2]<-"PropertyID"
colnames(property)
newdata<-merge(property,april,by="PropertyID")#数据合并
newdata$Status
names(newdata)
dim(newdata)/30
str(newdata)



#Give a distribution of blocked properties for each day in April. 
########figure 1#########
library(dplyr)
day_block<-newdata%>%
  filter(Status=="B")%>%
  group_by(Date)%>%
  summarise(Count=n())
day_block#对应每天处于block状态的properties数量
plot(ts(day_block$Count,start = 1),ylab="Number of blocked properties",xlab="Each day in April",
     main="The distribution of blocked properties for each day in April")
text(1:30,day_block$Count+1,day_block$Count,pch=20,cex=0.7)

########figure 2#########
day_block$Day<-weekdays(day_block$Date,abbreviate=T)#将对应的日期转换为对应每周中的the day of week
day_block$Day<-factor(day_block$Day,levels = c("周一","周二","周三", "周四", "周五", "周六", "周日" ),
                      labels = c("MON","TUE","WED","THU","FRI","SAT","SUN"))
library(ggplot2)
day_block
ggplot(day_block,aes(x=Day,y=Count,fill=Day))+
  geom_boxplot()+theme_bw()+labs(x = 'Day of the week', y = 'Number of blocked properties',
                                 title = "The number of properties to be blocked on each day of the week")+
  theme(plot.title = element_text(hjust=0.5,size=20))

########figure 3#########
day_block_2<-day_block%>%
  group_by(Day)%>%
  summarise(Mean=round(mean(Count)))#计算each day of the week的平均block状态数量
day_block_2<-day_block_2[order(day_block_2$Mean),]#从大到小排序
day_block_2$Day<-factor(day_block_2$Day,levels=c("FRI", "SAT", "THU", "SUN" ,"WED", "MON","TUE"),ordered = TRUE)
day_block_2

library(ggthemes)
ggplot(day_block_2,aes(x=Day,y=Mean,fill=Day,label=Mean))+geom_bar(stat="identity",position = "dodge")+labs(x = 'Day of the week', y = 'Number of blocked properties',
                                                                                                            title = "The average number of properties to be blocked on each day the week")+
  theme_stata()+scale_fill_stata()+theme(plot.title = element_text(hjust=0.5,size=20))+coord_flip()+geom_text(aes(y=Mean+0.01),position = position_dodge(0.9),vjust=-0.5)



#Which locations in the city are more likely to be blocked? 
block_loc<-data.frame(cbind(ifelse(newdata$Status=="B",1,0),newdata$Latitude,newdata$Longitude))#选出所有block状态的property
colnames(block_loc)<-c("Block_status","Lat","Lon")#修改变量名称
options(digits = 6)
head(block_loc)
# plot(block_loc[block_loc$Block_status==0,-1],pch=20)
# points(block_loc[block_loc$Block_status==1,-1],pch=20,col=2)

block_loc<-block_loc[block_loc$Block_status==1,]#只选取block状态的样本
nrow(block_loc)

########figure 4#########
library(ks)

H<-Hpi(x=block_loc[,-1])
fhat<-kde(x=block_loc[,-1],H=H)
plot(fhat,display="filled.contour2",main="The density heat map of blocked properties locations")#由包算出每个位置的block状态的密度概率并投射到经纬度上
points(block_loc[,-1],cex=0.4,pch=16)#投射原样本点


#ls blocking activity related to rental price or real estate value of the property?
library(dplyr)
block_loc$rental_price<-newdata[newdata$Status=="B","Price"]

block_loc$estate_value<-newdata[newdata$Status=="B","Annual Revenue LTM"]

str(block_loc)

newdata$rental_price<-newdata$Price

newdata$estate_value<-newdata$`Annual Revenue LTM`
########figure 5#########
library(ggplot2)
ggplot(newdata, aes(x = Latitude, y = Longitude)) +
  geom_point(aes(col=Status,size=rental_price))+theme_bw()+labs(title = "Scatterplot of status relate to rental price of the property")+
  theme(plot.title = element_text(hjust=0.5,size=20))


ggplot(block_loc, aes(x = LAT, y = LON)) +
  geom_point(aes(size=estate_value,col=rental_price))+
  theme_light()+
  stat_density2d(aes(alpha = stat(density)), geom = "raster", contour = FALSE,inherit.aes = TRUE)+
  labs(title = "The density distribution of blocked status relate to real estate value and rental price of the property")+
  theme(plot.title = element_text(hjust=0.5,size=20))

#############FINAL report########
library(gridExtra)
library(ggplot2)
library(readr)
april<- read_csv("ny_april_10009.csv")
property <- read_csv("ny_property_10009.csv")
names(property)
names(property)[2]<-"PropertyID"
colnames(property)
newdata<-merge(property,april,by="PropertyID")#数据合并
names(newdata)
dim(newdata)/30
str(newdata)

#######数据处理######
data.2<-newdata
data.2$Status<-ifelse(newdata$Status=="B",1,0)#1:"Block" 2:"Unblock"
data.2$Superhost<-ifelse(data.2$Superhost==FALSE,0,1)#1:TRUE 0:FALSE
str(data.2)

data.3<-select(data.2,c("Status","Price","price_norm","photo_room_ratio","Number of Photos","Count Reservation Days LTM",
                        "Count Available Days LTM","Count Blocked Days LTM",
                        "Max Guests","PropertyID","Host ID","Cleaning Fee",
                        "Neighborhood","Annual Revenue LTM","Occupancy Rate LTM","Number of Bookings LTM",
                        "Number of Reviews","Bedrooms","Bathrooms"))
summary(data.3)

y<-select(data.3,-c("PropertyID","Host ID","Neighborhood"))
t(summary(y))
y<-na.omit(y)
fit.all<-lm(Status~.,y)
str(data.4)
summary(fit.all)
relweighs(fit.all)

library(stargazer)
stargazer(fit.all, type="text",summary = T,
          title="Regression Results", single.row=TRUE,
          ci=TRUE, ci.level=0.95)
######################GLM#############
fit.glm<-glm(Status~.,data=y, family = binomial)
summary(fit.glm)
pred.s<-predict(fit.glm,data=y,type="response")#******
pred.p<-ifelse(pred.s>0.5,1,0)
pred.p

tabPD=table(y$Status,pred.p,dnn=c("实际样本","预测结果"))
sum(diag(prop.table(tabPD)))

summary(y)

summary(East_Village)

pre_Table<-data.frame(Price =c(40:2500), Annual.Revenue.LTM = 17088, price_norm = 1.73)
model_Prediction <- predict(ft.logit, newdata = pre_Table, type="response")
pre_Table<-cbind(pre_Table,model_Prediction);pre_Table

plot(x = pre_Table$Price, y = model_Prediction,xlab="Price",ylab="Predictions()",pch=18,col="lightskyblue")
lines(x = pre_Table$Price, model_Prediction,col = 2,lwd = 2,lty = 2)
legend("topleft",legend=c("1: Block","0: Unblock"))
summary(model_Prediction)


#MAPE
resid <- y$Status-pred.p
A_t<-y$Status
A_t[which(A_t == 0)] <- mean(A_t)
mean(abs(resid)/A_t)

resid <- outsample$Status-outPD
A_t<-outsample$Status
A_t[which(A_t == 0)] <- mean(A_t)
mean(abs(resid)/A_t)

mean(resid)


##outsample
ind<-sample(nrow(y),0.7*nrow(y))
insample<-y[ind,]
outsample<-y[-ind,]

ins.logit<-glm(Status~.,data=insample,family = binomial)
summary(ins.logit)

outPd<-predict(ins.logit,outsample,type="response")
outPD<-ifelse(outPd>0.5,1,0)

outltabpd=table(outsample$Status,outPD,dnn=c("实际样本","预测结果"))
outltabpd
sum(diag(prop.table(outltabpd)))#0.7

#MAPE
resid <- outsample$Status-outPD
A_t<-outsample$Status
A_t[which(A_t == 0)] <- mean(A_t)
mean(abs(resid)/A_t)

mean(resid)
