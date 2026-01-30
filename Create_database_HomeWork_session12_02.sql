create database Homework_session12_02;
-- create table
create table products(
	product_id serial primary key,
	name varchar(50),
	stock int
);
create table sales(
	sale_id serial primary key,
	product_id int references products(product_id),
	quantity int
);
-- Viết function cho trigger insert_sales
create or replace function f_insert_sales()
returns trigger as $$
declare
	v_stock int;
begin
	if tg_op = 'INSERT' then
		select stock into v_stock from products p where p.product_id = new.product_id;
		if not found then
			raise exception 'Sản phẩm không tồn tại!';
		end if;
		if v_stock < new.quantity then
			raise exception 'Số lượng tồn kho không đủ!';
		else
			update products set stock = stock - new.quantity where product_id = new.product_id;
			return new;
		end if;
	end if;
end;
$$ language plpgsql;
-- Viết TRIGGER BEFORE INSERT để kiểm tra tồn kho
create or replace trigger tg_insert_sales
before insert on sales
for each row
execute function f_insert_sales();
-- insert data
insert into products(name, stock) values
('May ban ca', 2),
('May ban nuoc', 3),
('May pha ca phe', 1);
insert into sales(product_id, quantity) values
(2, 3);
-- Kiểm tra
select * from sales;
select * from products;

-- Viết function cho trigger update stock
create or replace function f_update_stock()
returns trigger as $$
begin
	if tg_op = 'INSERT' then
		update products set stock = stock - new.quantity where product_id = new.product_id;
		return new;
	end if;
end;
$$ language plpgsql;
-- Viết TRIGGER AFTER INSERT để giảm số lượng stock trong products
create or replace trigger tg_update_stock
after insert on sales
for each row
execute function f_update_stock();
-- insert data
insert into sales(product_id, quantity) values
(2, 3);
-- kiểm tra
select * from sales;
select * from products;