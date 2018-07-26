select s.spacename , sum(cp.LONGVAL)
from SPACES s 
	INNER JOIN CONTENT c ON c.spaceid = s.spaceid 
    INNER JOIN CONTENTPROPERTIES cp ON cp.contentid = c.contentid 
where c.contenttype = 'ATTACHMENT' and cp.propertyname = 'FILESIZE' GROUP BY s.spacename;

