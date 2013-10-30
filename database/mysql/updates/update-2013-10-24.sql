alter table `billing_on_payment` add column `total_refund` decimal(10,2);
alter table `billing_on_payment` add column `total_discount` decimal(10,2);
alter table `billing_on_payment` change column `payment` `total_payment` decimal(10,2) NOT NULL;

alter table `billing_on_item` add column `paid` decimal(10,2) NOT NULL DEFAULT 0.00;
alter table `billing_on_item` add column `refund` decimal(10,2) NOT NULL DEFAULT 0.00;
alter table `billing_on_item` add column `discount` decimal(10,2) NOT NULL;