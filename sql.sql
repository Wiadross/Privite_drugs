INSERT INTO `jobs` (`name`, `label`, `whitelisted`, `SecondaryJob`, `lvl`) VALUES
('drugs1', 'Chujnia', 1, 0, 'kontrakt');

INSERT INTO `addon_account` (`name`, `label`, `shared`) VALUES
('society_drugs1', 'test', 1);

INSERT INTO `addon_account_data` (`id`, `account_name`, `money`, `account_money`, `owner`) VALUES
(4, 'society_drugs1', 3878, 0, NULL);

INSERT INTO `addon_inventory` (`name`, `label`, `shared`) VALUES
('society_drugs1', 'test', 1);

INSERT INTO `addon_inventory_items` (`id`, `inventory_name`, `name`, `count`, `owner`) VALUES
(1, 'society_drugs1', 'handcuffs', 10, NULL),
(2, 'society_drugs1', 'ekstazy', 0, NULL),
(3, 'society_drugs1', 'ekstazy1', 0, NULL),
(4, 'society_drugs1', 'pistol_ammo', 0, NULL),
(0, 'society_drugs1', 'sandwich', 1, NULL);

INSERT INTO `datastore` (`name`, `label`, `shared`) VALUES
('society_drugs1', 'test', 1);

INSERT INTO `datastore_data` (`id`, `name`, `owner`, `data`) VALUES
(432, 'society_drugs1', NULL, '{}'),
(433, 'society_drugs1', NULL, '{}');

INSERT INTO `job_grades` (`id`, `job_name`, `grade`, `name`, `label`, `salary`, `skin_male`, `skin_female`) VALUES
(2147483647, 'drugs1', 1, 'oponent', 'Oponent', 500, '', ''),
(2147483647, 'drugs1', 2, 'szef', 'Szef', 500, '', '');

INSERT INTO `items` (`name`, `label`, `limit`, `rare`, `can_remove`) VALUES
('meth', 'Metamfetamina', 150, 0, 1),
('meth_pooch', 'Torebka Metamfetaminy', 60, 0, 1);

