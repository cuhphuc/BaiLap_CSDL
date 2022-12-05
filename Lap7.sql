--------------câu 1a-----------------
IF OBJECT_ID('fn_tuoi_nv') IS NOT NULL
	DROP FUNCTION FN_TUOI_NV
GO
CREATE FUNCTION fn_tuoi_nv(@MaNhanVien nvarchar(9))
returns int 
AS
	BEGIN	
		RETURN (SELECT YEAR(GETDATE())-YEAR(ngsinh)
		FROM NHANVIEN WHERE MANV=@MaNhanVien)
	END

PRINT N'TUỔI NHÂN VIÊN :' +CAST(dbo.fn_tuoi_nv('003')AS VARCHAR (5))
SELECT * FROM NHANVIEN

--------------câu 1b-----------------
select count(mada) from PHANCONG where MA_NVIEN='001'
select * from PHANCONG
IF OBJECT_ID('fn_dean_nv') IS NOT NULL
	DROP FUNCTION FN_TUOI_NV
GO
CREATE FUNCTION fn_dean_nv(@MaNhanVien nvarchar(9))
returns int 
AS
	BEGIN	
		RETURN (select count(mada) from PHANCONG
		WHERE MA_NVIEN=@MaNhanVien)
	END

PRINT N'SỐ LƯỢNG ĐỀ ÁN CỦA NHÂN VIÊN :' +CAST(dbo.fn_dean_nv('003')AS VARCHAR (5))
--------------câu 1c-----------------
IF OBJECT_ID('fn_phai_nv') IS NOT NULL
	DROP FUNCTION fn_phai_nv
GO
CREATE FUNCTION fn_phai_nv(@gt nvarchar(4))
returns int 
AS
	BEGIN	
		RETURN (select count(*) from NHANVIEN
		WHERE UPPER(Phai)=UPPER(@gt)
	END
	
select * from NHANVIEN
PRINT 'SỐ LƯỢNG NHÂN VIÊN NAM:' +CAST(dbo.fn_phai_nv('Nam')AS VARCHAR (5))
PRINT 'SỐ LƯỢNG NHÂN VIÊN NỮ :' +CAST(dbo.fn_phai_nv(N'Nữ')AS VARCHAR (5))

--------------câu 1D-----------------
declare @luongtb float
select @luongtb=avg(luong) from NHANVIEN
INNER JOIN PHONGBAN on PHONGBAN.MAPHG=NHANVIEN.PHG
WHERE UPPER(TenPHG)=UPPER(@tenphongban) 

INSERT INTO @listNV
	SELECT CONCAT(Honv,' ',TenLot,' ',TenNV),luong from NHANVIEN
	WHERE luong>@luongtb 

if object_id('fn_luong_nv_pb') is not null
	drop function fn_luong_nv_pb
go
create function fn_luong_nv_pb(@tenphongban nvarchar(21))
returns @listNV table(Hoten nvarchar(60),luong float)
as 
	begin
		declare @luongtb float
		select @luongtb=avg(luong) from NHANVIEN
		INNER JOIN PHONGBAN on PHONGBAN.MAPHG=NHANVIEN.PHG
		WHERE UPPER(TenPHG)=UPPER(@tenphongban) 

		INSERT INTO @listNV
		SELECT CONCAT(Honv,' ',TenLot,' ',TenNV),luong from NHANVIEN
		WHERE luong>@luongtb 

	return
	end
select * from PHONGBAN
select * from dbo.fn_luong_nv_pb(N'Điều Hành');

select avg(luong) from NHANVIEN
		INNER JOIN PHONGBAN on PHONGBAN.MAPHG=NHANVIEN.PHG
		WHERE upper(TenPHG)=upper(N'Điều Hành')
--------------------------câu 1e-----------------
select PHONGBAN.TENPHG,CONCAT(honv,' ',tenlot,' ',tennv),count(mada)
from PHONGBAN INNER JOIN dean on dean.PHONG=PHONGBAN.MAPHG
inner join NHANVIEN on NHANVIEN.PHG=PHONGBAN.MAPHG
WHERE PHONGBAN.MAPHG=@MaPB
GROUP BY tenphg,honv,TENLOT,tennv

if object_id('fn_pb_nv_dean') is not null
	drop function fn_pb_nv_dean
go
create function fn_pb_nv_dean(@MaPB int)
returns @listPB table(TenPhong nvarchar(20),HoTenNV nvarchar(60),slDuan int)
as
	begin
		insert into @listPB
		select PHONGBAN.TENPHG,CONCAT(honv,' ',tenlot,' ',tennv),count(mada)
		from PHONGBAN INNER JOIN dean on dean.PHONG=PHONGBAN.MAPHG
		inner join NHANVIEN on NHANVIEN.PHG=PHONGBAN.MAPHG
		WHERE PHONGBAN.MAPHG=@MAPB
		GROUP BY tenphg,honv,TENLOT,tennv
	return
	end

select * from dbo.fn_pb_nv_dean('003');

--------------------------câu 2a-----------------
select HONV,TENNV,TENPHG, DIADIEM FROM PHONGBAN
INNER JOIN DIADIEM_PHG ON DIADIEM_PHG.MAPHG = PHONGBAN.MAPHG
INNER JOIN NHANVIEN ON NHANVIEN.PHG = PHONGBAN.MAPHG

create view v_DD_PhongBan
as
select HONV,TENNV,TENPHG, DIADIEM FROM PHONGBAN
INNER JOIN DIADIEM_PHG ON DIADIEM_PHG.MAPHG = PHONGBAN.MAPHG
INNER JOIN NHANVIEN ON NHANVIEN.PHG = PHONGBAN.MAPHG

SELECT * FROM v_DD_PhongBan
--------------------------câu 2b-----------------
select TENNV,LUONG,YEAR(GETDATE())-YEAR(NGSINH)AS 'TUỔI' FROM NHANVIEN

CREATE VIEW v_TuoiNV
AS
SELECT TENNV,LUONG,YEAR(GETDATE())-YEAR(NGSINH)AS 'TUỔI' FROM NHANVIEN

SELECT * FROM v_TuoiNV
--------------------------câu 2c-----------------
if object_id('vw_PB') is not null
	drop function vw_PB
go
create view vw_PB(TenPhongBan,HoTenTP,SLNV)
as
	select Top1 tenphg,count(nv.MaNV),CONCAT(tp.honv,' ',tp.tenlot,' ',tp.tennv)
	from NHANVIEN as nv inner join PHONGBAN on PHONGBAN.MAPHG=nv.PHG
		inner join NHANVIEN as tp on tp.MANV=PHONGBABN.TRPHG
	group by TENPHG,tp,TENNV,tpHONV,tp.TENLOT
	order by count(nv.Manv) desc

select * from vw_PB