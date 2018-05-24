//
//  SqlStatement.h
//  CloudClassRoom
//
//  Created by rgshio on 15/12/14.
//  Copyright © 2015年 like. All rights reserved.
//

#ifndef SqlStatement_h
#define SqlStatement_h

#pragma mark - INSERT
#define sql_insert_download_course(a ,fileType) [NSString stringWithFormat:@"insert into download_course (course_sco_id,status,progress,create_time,file_type) VALUES ('%@', 0, 0, '%@','%@')", a, [MANAGER_UTIL getDateTime:TimeTypeAll],fileType]
#define sql_insert_chat(chat, a) [NSString stringWithFormat:@"insert into chat (id, relation_id, user_id, realname, content, avatar, create_time) VALUES ('%d', '%@', '%d', '%@', '%@', '%@', '%@')", chat.ID, a, chat.userID, chat.realname, chat.content, chat.avatar, chat.createTime]
#define sql_insert_channel(a, course) [NSString stringWithFormat:@"insert into channel (channel_id, course_id, sn) VALUES ('%@', '%d', %d)", a, course.courseID, course.sn]
#define sql_insert_class_course(course) [NSString stringWithFormat:@"insert into class_course (class_id, course_id) VALUES ('%@', '%d')", course.classID, course.courseID]
#define sql_insert_notice(notice) [NSString stringWithFormat:@"insert into notice (id, content, create_time, is_read, uuid) VALUES ('%d', '%@', '%@', '%d', '%@')", notice.ID, notice.content, notice.createTime, notice.isRead, notice.uuid]
#define sql_insert_photo(photo, a) [NSString stringWithFormat:@"insert into photo (id, realname, title, zan_count, zan, url, file_name, create_time, user_id, relation_id) VALUES ('%d', '%@', '%@', '%d', '%d', '%@', '%@', '%@', '%d', '%@')", photo.ID, photo.realname, photo.title, photo.zanCount, photo.zan, photo.url, photo.filename, photo.createTime, photo.userID, a]

#pragma mark - DELETE
#define sql_delete_chat(a) [NSString stringWithFormat:@"delete from chat where ID in %@", a]
#define sql_delete_user_course(a) [NSString stringWithFormat:@"delete from user_course where course_id = '%d'", a]
#define sql_delete_download_course(a, b) [NSString stringWithFormat:@"delete from download_course where course_sco_id = '%@' and file_type like '%@'", a, b == 0 ? @"%%" : (b == 3 ? @"%3" : @"%4")]
#define sql_delete_type_download_course(a) [NSString stringWithFormat:@"delete from download_course where course_sco_id like '%d_%%'", a]
#define sql_delete_photo(a) [NSString stringWithFormat:@"delete from photo where ID in %@", a]
#define sql_delete_channel(a) [NSString stringWithFormat:@"delete from channel where channel_id = '%@'", a]
#define sql_delete_notice @"delete from notice"
#define sql_delete_course(a) [NSString stringWithFormat:@"delete from course where (category_id like '%@,%%') or (category_id like '%%,%@') or (category_id like '%%,%@,%%') or (category_id like '%@') ", a, a, a, a]
#define sql_delete_class_course [NSString stringWithFormat:@"delete from class_course where class_id = '%@' ", [DataManager sharedManager].classID]

#pragma mark - SELECT
#define sql_select_scorm(a) [NSString stringWithFormat:@"select * from scorm where course_sco_id = '%@'", a]
#define sql_select_scorm_child(a) [NSString stringWithFormat:@"select * from scorm where type = 1 and course_id = '%@'", a]
#define sql_select_scorm_list @"select * from scorm where learn_times > 0"
#define sql_select_course(a) [NSString stringWithFormat:@"select * from course where id = '%@'", a]
#define sql_select_session(a) [NSString stringWithFormat:@"select ifnull(session_time, '0') from scorm where course_id = '%d'", a]
#define sql_select_course_list(a, b) [NSString stringWithFormat:@"select * from download_course inner join scorm on scorm.course_sco_id = download_course.course_sco_id inner join course on course.id = scorm.course_id where download_course.course_sco_id like '%d_%%' and status %@ 4 order by scorm.id ", a, (b==0?@"<>":@"=")]
#define sql_select_download_course(a) [NSString stringWithFormat:@"select distinct course.id,course_name,course_introduction,logo,course_type,courseware_type,lecturer,lecturer_avatar,lecturer_introduction,elective_count,comment_score,comment_count,period,credit,is_test,course.create_time,deleted,course_no,definition from course inner join scorm on scorm.course_id = course.id inner join download_course on download_course.course_sco_id = scorm.course_sco_id where download_course.status %@ 4 order by download_course.id desc", (a==0?@"<>":@"=")]
#define sql_select_course_no_count(a) [NSString stringWithFormat:@"select count(course_no) from course inner join scorm on scorm.course_id = course.id inner join download_course on download_course.course_sco_id = scorm.course_sco_id where course_no = '%@'", a]
#define sql_select_notice(a) [NSString stringWithFormat:@"select * from notice where uuid = '%@' order by id desc", a]
#define sql_select_read_count(a) [NSString stringWithFormat:@"select count(id) from notice where is_read = 0 and uuid = '%@'", a]
#define sql_select_is_read(a) [NSString stringWithFormat:@"select * from notice where id = '%@'", a]
#define sql_select_course_progress(a) [NSString stringWithFormat:@"select * from user_course where course_id = '%d'", a]
#define sql_select_max_id(a, b) [NSString stringWithFormat:@"select max(id) from %@ where relation_id = '%@'", a, b]
#define sql_select_user_course_single(a) [NSString stringWithFormat:@"select * from user_course inner join course on course_id = course.id where course_id = '%@'", a]
#define sql_select_user_course_finish(a) [NSString stringWithFormat:@"select * from user_course inner join course on course_id = course.id where complete_year = '%@' and status = 1 order by elective_time desc", a]
#define sql_select_user_course_study(a) [NSString stringWithFormat:@"select * from user_course inner join course on course_id = course.id where course_type = '%@' and status = 0 order by elective_time desc", a]
#define sql_select_channel(a) [NSString stringWithFormat:@"select * from channel inner join course on course_id = course.id where channel_id = '%@' order by sn", a]
#define sql_select_chat_avatar @"select user_id, avatar from (select user_id, avatar from chat group by user_id, avatar order by create_time) group by user_id having count(user_id) > 1"

#define sql_select_scorm_list_course(a) [NSString stringWithFormat:@"select * from scorm left join download_course on scorm.course_sco_id = download_course.course_sco_id where course_id = '%@'", a]


#define sql_new_select_scorm_list(a) [NSString stringWithFormat:@"select * from scorm where course_id = '%@'", a]

#define sql_download_course_status(a, b)  [NSString stringWithFormat:@"select status, file_type from download_course  where course_sco_id = '%@' and file_type like '%@'", a, (b == 3)? @"%mp3": @"%mp4" ]

#define sql_download_course_status_mp4_pdf(a)  [NSString stringWithFormat:@"select status, file_type from download_course  where course_sco_id = '%@' and (file_type like '%@' or file_type = '1.pdf')", a, @"%mp4"]

#define sql_download_course_status_mp3(a, b)  [NSString stringWithFormat:@"select status from download_course  where course_sco_id = '%@' and file_type = '%@'", a, b]

#define sql_select_download_course_sco_count(a, b) [NSString stringWithFormat:@"select count(course_sco_id) from download_course where course_sco_id like '%@_%%' and status %@", a, b?@"= 4":@"<> 6"]

#define sql_select_download_course_sco_count_mp4_pdf(a, b) [NSString stringWithFormat:@"select count(course_sco_id) from download_course where course_sco_id like '%@_%%' and status %@ and (file_type like '%@' or file_type like '1.pdf')", a, b ? @"= 4" : @"<> 6", @"%mp4"]

#define sql_select_download_course_sco_count_mp3(a, b) [NSString stringWithFormat:@"select count(course_sco_id) from download_course where file_type like '%@' and course_sco_id like '%@_%%' and status %@",@"%mp3", a, b?@"= 4":@"<> 6"]

#define sql_select_download_course_count(a) [NSString stringWithFormat:@"select count(course_sco_id) from download_course where status %@ 4", a==0?@"<>":@"="]

#define sql_select_download_course_scorm @"select * from scorm inner join download_course on scorm.course_sco_id = download_course.course_sco_id inner join course on scorm.course_id = course.id where status <> 4 and status <> 6 "

#define sql_select_download_course_scorm_pdf_mp4 @"select * from scorm inner join download_course on scorm.course_sco_id = download_course.course_sco_id inner join course on scorm.course_id = course.id where status <> 4 and status <> 6 and (file_type like '%mp4' or file_type = '1.pdf')"

#define sql_select_download_course_scorm_mp3 @"select * from scorm inner join download_course on scorm.course_sco_id = download_course.course_sco_id inner join course on scorm.course_id = course.id where status <> 4 and status <> 6 and file_type = '1.mp3'"
#define sql_select_scrom_lesson_location_duration(a) [NSString stringWithFormat:@"select lesson_location, duration, sco_name from scorm where course_sco_id = '%@'", a]
#pragma mark - UPDATE
#define sql_update_elective_count(a, b) [NSString stringWithFormat:@"update course set elective_count = %d where id = %d", a, b]
#define sql_update_course_progress(a, b) [NSString stringWithFormat:@"update user_course set progress = %.3f where course_id = %d", a, b]
#define sql_update_lesson_location(a, b) [NSString stringWithFormat:@"update scorm set lesson_location = %@ where course_sco_id = '%@'", a, b]
#define sql_update_last_learn(a) [NSString stringWithFormat:@"update scorm set last_learn_time = '%@' where course_sco_id = '%@'", [MANAGER_UTIL getDateTime:TimeTypeAll], a]
#define sql_update_lastLearnTime_lessonLocation(a, b, c) [NSString stringWithFormat:@"update scorm set last_learn_time = '%@', lesson_location = '%@' where course_sco_id = '%@'", a, b, c]//课程同步
#define sql_update_session_time(a, b) [NSString stringWithFormat:@"update scorm set session_time = %d where course_sco_id = '%@'", a, b]
#define sql_update_learn_times(a, b) [NSString stringWithFormat:@"update scorm set learn_times = %d where course_sco_id = '%@'", a, b]
#define sql_update_clear_learn_times(a) [NSString stringWithFormat:@"update scorm set learn_times = 0, session_time = 0 where course_id = '%@'", a]
#define sql_update_set_duration(a, b) [NSString stringWithFormat:@"update scorm set duration = %@ where course_sco_id = '%@'", a, b]
#define sql_update_set_filename(a, b) [NSString stringWithFormat:@"update download_course set file_type = '%@' where course_sco_id = '%@' and file_type like '%@' ", a, b, @"%4"]
#define sql_update_set_readed(a, b) [NSString stringWithFormat:@"update notice set is_read = 1 where ID = %d and uuid = '%@'", a, b]
#define sql_update_set_zan(a, b) [NSString stringWithFormat:@"update photo set zan_count = %d, zan = 1 where id = %d", a, b]
#define sql_update_set_zan_count(a, b) [NSString stringWithFormat:@"update photo set zan_count = %d where id = '%d'", a, b]
#define sql_update_download(a, b, c, d, e) a==DownloadTypeCourse ? [NSString stringWithFormat:@"update download_course set status = %d, progress = %f where course_sco_id = '%@' and file_type like '%@'", b, c, d,e == 0 ? @"%%" : (e == 3 ? @"%3" : @"%4")] : [NSString stringWithFormat:@"update download_resource set status = %d, progress = %f where resource_id = '%@'", b, c, d]

#define sql_newUpdate_download(a, b, c, d, e) a==DownloadTypeCourse ? [NSString stringWithFormat:@"update download_course set status = %d, progress = %f where course_sco_id = '%@' and file_type like '%@' and status <>4", b, c, d,e == 0 ? @"%%" : (e == 3 ? @"%3" : @"%4")] : [NSString stringWithFormat:@"update download_resource set status = %d, progress = %f where resource_id = '%@'", b, c, d]
#define sql_update_chat_avatat(chat) [NSString stringWithFormat:@"update chat set avatar = '%@' where user_id = '%d'", chat.avatar, chat.userID]

#endif /* SqlStatement_h */
