-- Restaurant Owner
-- 5  Tables
-- 1x Fact, 4x Dimension
-- search googel, how to add foreign key
-- write sql 3-5 queries analyze data
-- 1x subquery/ with 
--sqllite command

.mode markdown
.header on

/* โจทย์เป็นข้อมูลเมนู Pizza ทั้งหมด ที่มีขาย ในร้าน pizza สาขาต่างๆ ที่ดูแลทั้งหมด โดยจะมีข้อมูลหลักๆ มีในส่วนของ unit price, สาขาที่ขาย, ผู้จัดการสาขาย่อยที่ดูแล, จังหวัดที่มีขายเมนูดังกล่าว

ตาราง Fact จะมี 1 ตาราง และ มี dim 4 ตาราง ซึ่ง ประกอบไปด้วย 

Restaurant(ชื่อร้านสาขาที่ขายเมนู),Province(ชื่อจังหวัดที่มีขายเมนู นั้นๆ),Director(ชื่อผู้จัดการสาขาย่อย),Type(ชนิดของ pizza ที่มีขาย)

Remakr: raw data มาจาก kaggle แต่มีการปรับแต่งข้อมูล มีการตัดบางคอลัมม์ที่ไม่จำเป็น และมีการเพิ่มบางคอลัมม์ เพิ่มเติม 

https://www.kaggle.com/datasets/datafiniti/pizza-restaurants-and-the-pizza-they-sell?select=Datafiniti_Pizza_Restaurants_and_the_Pizza_They_Sell_May19.csv

*/
  
-- สร้าง Fact Table  
create table Menu (
  Menu_ID int primary key,
  Menu_Name char,
  Menu_Price real,
  Restaurant_ID int,
  Province_ID int,
  Director_ID int,
  Type_ID int,
  
  foreign key (Restaurant_ID) references Restaurant(Restaurant_ID),
  foreign key (Province_ID) references Province(Province_ID),
  foreign key (Type_ID) references Type(Type_ID)
  
);

insert into Menu values 
  (1,'Cheese Pizza',12,1,1,1,1),
  (2,'Pizza Cookie',18,2,2,1,1),
  (3,'Pizza Blanca',20,3,3,1,1),
  (4,'Small Pizza',23,4,4,1,1),
  (5,'Pizza Sub',14,5,5,2,1),
  (6,'White Pizza',15,5,5,2,1),
  (7,'Two Topping Pizza',17,6,6,1,1),
  (8,'Three Or More Topping Pizza',30,6,6,1,1),
  (9,'Pizza',22,7,7,2,1),
  (10,'Kids Cheese Pizza',19,8,4,3,2),
  (11,'Create Your Own Pizza',12,8,4,3,2),
  (12,'Prosciutto Arugula Pizza',15,8,4,3,2),
  (13,'Kids Pepperoni Pizza',18,8,4,3,2),
  (14,'Three Cheese Pizza',11,9,7,3,2);

-- สร้าง Dim1 Table (Restaurant)
create table Restaurant (
  Restaurant_ID int primary key,
  Restaurant_Name char
);

insert into Restaurant values 
  (1,'Shotgun Dans Pizza'),
  (2,'Sauce Pizza Wine'),
  (3,'Mios Pizzeria'),
  (4,'Hungry Howies Pizza'),
  (5,'Spartan Pizzeria'),
  (6,'La Vals'),
  (7,'Brickyard Pizza'),
  (8,'Carrabbas Italian Grill'),
  (9,'Domenicos Jr');

-- ส้ราง Dim2 Table (Province)

create table Province (
  Province_ID int primary key ,
  Province_Name char
  );

insert into Province values
  (1,'AR'),
  (2,'AZ'),
  (3,'OH'),
  (4,'MI'),
  (5,'MD'),
  (6,'CA'),
  (7,'FL');

-- สร้าง Dim3 Table (Director)

create table Director (
  Director_ID int primary key ,
  Director_Name char
  );

insert into Director values
  (1,'John'),
  (2,'Peter'),
  (3,'Alice');

-- สร้าง Dim4 Table (Type)

create table Type (
  Type_ID int primary key ,
  Type_Name char
  );

insert into Type values
  (1,'American'),
  (2,'Italian');

------เขียน SQL 3 ชุดเพื่อดึงข้อมูลตามโจทย์ที่อยากได้----------

/* SQL NO.1 : อยากทราบ TOP 5 เมนู PIZZA ในด้านมูลค่าต่อชิ้น ที่ผู้จัดการสาขา John ดูแล มีอะไรบ้าง 
      1) ทำการ join ทุกตารางเข้าด้วยกัน แล้วตั้งเป็น temporary table ชื่อ 'Menu_List' 
      2) ทำการเลือก column จาก ตาราง Menu_List ที่ต้องการวิเคราะห์ คือ Menu_Name,Menu_Price,Director_Name,Type_Name
      3) สร้าง column ใหม่ ชื่อ Value-Status โดย ถ้า column Menu_Price มากกว่า 15 USD ระบุ high value ถ้าน้อยกว่านั้น ระบุ normal
      4) ทำการ filter เฉพาะเมนุ pizza ที่ มี high value  และ Director ประจำสาขาที่ดูแลเป็น John           
      5) สุดท้ายเรียงลำดับ ลิสต์ของ Pizza จากราคาสูงไป ราคาต่ำ
*/


with Menu_List as (

select * from Menu as me
inner join Restaurant as re on me.Restaurant_ID=re.Restaurant_ID
inner join Province as pr on me.Province_ID=pr.Province_ID
inner join Director as di on me.Director_ID=di.Director_ID 
inner join Type as ty on me.Type_ID=ty.Type_ID

)

select 
  Menu_Name,
  Menu_Price,
  Director_Name,
  Type_Name,
  
  case 
    when Menu_Price > 15 then 'High Value'
    else 'Normal'
  end as Value_Status

from Menu_List
  
where Value_Status == 'High Value' and Director_Name=='John'
order by Menu_Price desc limit 5;


-- SQL NO.2 :  อยากทราบว่า ผู้จัดการคนไหน ดูแล manu pizza ที่มีค่าเฉลี่ยรวมกันสูงสุด

select 
  
  Director_Name,
  avg(Menu_Price) as 'Average_MenuPrice'
  
  
from Menu 

join Director on Menu.Director_ID=Director.Director_ID

group by Director_Name
order by avg(Menu_Price) desc; 


-- SQL NO.3 :  อยากทราบ menu pizza 3 อันดับแรก ที่มีราคาสูงสุด ในจังหวัด Miami (Mi) 

select 
  Menu_Name,
  Menu_Price,
  Province_Name
  
from Menu

join Province on Menu.Province_ID=Province.Province_ID
 
where Province_Name='MI'
order by Menu_Price desc limit 3;

  




