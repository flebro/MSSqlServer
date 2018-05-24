use [master]
go

if exists (select top(1) 1 from sys.databases where name = 'AddressBook')
begin
	--On passe la base en single user
	-- 'with rollback immediate' abandonne les transactions incompletes en cours et déconnecte les utilisateurs
	alter database [AddressBook] Set
		single_user with rollback immediate

	drop database [AddressBook]
end
go

create database [AddressBook]
on primary --Fichier de données
 (
	name=AddressBook_dat --Nom logique du fichier
	,filename='C:\chemin\AddressBook.mdf'
	,size=64mb
	,maxsize=2gb
 )
log on
(
	name=AddressBook_log --Nom logique du fichier
	,filename='C:\chemin\AddressBook.ldf'
	,size=64mb
	,maxsize=UNLIMITED --2TO pour les logs et 16TO pour les data
)
go

use [AddressBook]
