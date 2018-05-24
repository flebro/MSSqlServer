use [master]
go

if exists (select top(1) 1 from sys.databases where name = 'AddressBook')
begin
	drop database [AddressBook]
end

create database [AddressBook]
go