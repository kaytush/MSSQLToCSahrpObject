DECLARE @TableName sysname = 'SANCTION_LIST'
DECLARE @Result varchar(max) = 'public class ' + @TableName + '
{'

SELECT @Result = @Result + '
    public ' + ColumnType + NullableSign + ' ' + ColumnName + ' { get; set; }
'
FROM
(
    SELECT 
        replace(col.name, ' ', '_') ColumnName,
        column_id ColumnId,
        CASE 
            WHEN col.is_identity = 1 THEN 'int'  -- Assuming the identity column is of type 'bigint'
            WHEN typ.name = 'bigint' THEN 'long'
            WHEN typ.name = 'binary' THEN 'byte[]'
            WHEN typ.name = 'bit' THEN 'bool'
            WHEN typ.name = 'char' THEN 'string'
            WHEN typ.name IN ('date', 'datetime', 'datetime2', 'smalldatetime') THEN 'DateTime'
            WHEN typ.name = 'datetimeoffset' THEN 'DateTimeOffset'
            WHEN typ.name = 'decimal' THEN 'decimal'
            WHEN typ.name = 'float' THEN 'double'
            WHEN typ.name IN ('image', 'varbinary') THEN 'byte[]'
            WHEN typ.name IN ('int', 'smallint') THEN 'int'
            WHEN typ.name = 'money' THEN 'decimal'
            WHEN typ.name IN ('nchar', 'ntext', 'nvarchar', 'text', 'varchar') THEN 'string'
            WHEN typ.name = 'numeric' THEN 'decimal'
            WHEN typ.name = 'real' THEN 'float'
            WHEN typ.name = 'time' THEN 'TimeSpan'
            WHEN typ.name = 'timestamp' THEN 'long'
            WHEN typ.name = 'tinyint' THEN 'byte'
            WHEN typ.name = 'uniqueidentifier' THEN 'Guid'
            ELSE 'UNKNOWN_' + typ.name
        END ColumnType,
        CASE 
            WHEN col.is_nullable = 1 AND typ.name IN ('bigint', 'bit', 'date', 'datetime', 'datetime2', 'datetimeoffset', 'decimal', 'float', 'int', 'money', 'numeric', 'real', 'smalldatetime', 'smallint', 'smallmoney', 'time', 'tinyint', 'uniqueidentifier') 
            THEN '?' 
            ELSE '' 
        END NullableSign
    FROM sys.columns col
        JOIN sys.types typ ON col.system_type_id = typ.system_type_id AND col.user_type_id = typ.user_type_id
    WHERE object_id = object_id(@TableName)
) t
ORDER BY ColumnId

SET @Result = @Result  + '
}'

PRINT @Result
