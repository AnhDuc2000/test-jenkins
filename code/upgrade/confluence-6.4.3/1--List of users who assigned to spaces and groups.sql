SELECT spacename, spacekey, group_name, lower_user_name, email_address, LAST_LOG_IN FROM (                
                      SELECT distinct s.spacename, s.spacekey, g.group_name, u.lower_user_name, u.email_address, DATE_FORMAT(l.successdate, '%Y-%m-%d') AS LAST_LOG_IN
                        FROM SPACEPERMISSIONS sp
                          JOIN SPACES s ON s.spaceid = sp.spaceid
                          JOIN cwd_group g ON sp.permgroupname = g.group_name
                          JOIN cwd_membership m ON g.id = m.parent_id
                          JOIN cwd_user u ON m.child_user_id = u.id     
                          JOIN user_mapping um ON um.username = u.lower_user_name
                          JOIN logininfo l ON um.user_key = l.username
                        WHERE 
                          g.group_name <> 'confluence-users'   
                          AND g.ACTIVE = 'T'
                          AND u.ACTIVE = 'T'                          
                      UNION                      
                      SELECT distinct s.spacename, s.spacekey, '' group_name, u.lower_user_name, u.email_address, DATE_FORMAT(l.successdate, '%Y-%m-%d') AS LAST_LOG_IN
                        FROM SPACES s
                         JOIN SPACEPERMISSIONS p ON s.SPACEID = p.SPACEID
                         JOIN user_mapping m ON p.PERMUSERNAME = m.user_key
                         JOIN cwd_user u ON m.username = u.lower_user_name                  
                         JOIN logininfo l ON m.user_key = l.username
                         WHERE u.ACTIVE = 'T'                                            
                
                    ) a                    
                order by spacename, spacekey, group_name, lower_user_name;