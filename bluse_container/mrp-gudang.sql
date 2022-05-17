------------------------------CREDITS------------------------------
--------        Script made by Bluse and Invrokaaah        --------
------   Copyright 2021 BluseStudios. All rights reserved   -------
-------------------------------------------------------------------

INSERT INTO `addon_account` (`name`, `label`, `shared`) VALUES
('gudang',	'Gudang',	0);

INSERT INTO `addon_inventory` (`name`, `label`, `shared`) VALUES
('gudang',	'Gudang',	0);

INSERT INTO `datastore` (`name`, `label`, `shared`) VALUES
('gudang',	'Gudang',	0);

DROP TABLE IF EXISTS `gudang`;
CREATE TABLE `gudang` (
  `id` int(11) NOT NULL,
  `identifier` varchar(50) NOT NULL,
  `gudangName` varchar(50) NOT NULL,
PRIMARY KEY (`id`)
);

ALTER TABLE `gudang`
MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=4;
COMMIT;
