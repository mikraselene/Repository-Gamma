clc;
clear;

id = [1, 2, 3];
name = ["Michael", "Hardaway", "Grace"];
sex = ["M", "M", "F"];
s_class = [6, 6, 6];
city = ["Chicago"; "Orlando"; "Boston"];

exams(1) = struct('Math', 95, 'English', 93, 'Music', 88, 'Sports', 92);
exams(2) = struct('Math', 90, 'English', 82, 'Music', 78, 'Sports', 92);
exams(3) = struct('Math', 91, 'English', 98, 'Music', 96, 'Sports', 87);

for i = 1:3
    students(i).ID = id(i);
    students(i).Name = name(i);
    students(i).Sex = sex(i);
    students(i).Class = s_class(i);
    students(i).City = city(i);
    students(i).Exams = exams(i);
    students(i).Total = 0;
    students(i).Average = 0;
end

students = Solution(students);

function [students] = Solution(students)
    for i = 1:3
        total = students(i).Exams.Math ...
            + students(i).Exams.English ...
            +students(i).Exams.Music ...
            +students(i).Exams.Sports;
        students(i).Total = total;
        students(i).Average = total / 4;
        fprintf('%10s: Total = %d, Average = %.2f\n', ...
            students(i).Name, students(i).Total, students(i).Average)
    end
end

% 就这样吧qwq不会别的好方法了qwq
