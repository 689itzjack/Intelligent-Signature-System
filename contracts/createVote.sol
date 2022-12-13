// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "hardhat/console.sol";

contract createVote{

    
    struct Student{//This data will be taken from the student's account, 
        uint year_coursing;
        string studentFaculty;
        uint idStudent; 
        string studentName;
        string emailStudent;
        uint phoneStudent;
    }
    struct Exam{
        string new_examDay;
        string new_examHour;
        uint moedExam;
    }
    struct Course{
        uint idCourse;
        uint semesterTeachingCourse;
        string nameCourse;
        Exam newExamCourse;
    }
    
//==========================================GLOBAL VARIABLES==========================================
    address owner;
    address address_Student;//this is the account student of metamask that every student must to have for make a vote.
    Student new_Student;//Contains data student
    bool student_Created = false;
    Course newCourse;
    bool createdCourse = false;
    address[] students_Voted;
    string[] voting_Dates;
    bool IamReady = false;
    bool hasVoted = false;
    uint ethersContract; //maybe will be quited.
    

//=======================================================CONSTRUCTOR========================================================

    constructor(string[] memory dates, uint ethContract){
        owner = msg.sender;
        uint index = 0;
        while(index < dates.length){
            voting_Dates.push(dates[index]);
            index++;
        }
        ethersContract = ethContract;
    }//["2/22/34","2/22/34","4/22/34"],100

//=========================================INITIALIZING STUDENT DATA============================

    function createStudent(uint _year_coursing, string memory _studentFaculty, uint _idStudent,
    string memory _studentName, string memory _emailStudent, uint _phoneStudent) public {
        require((_year_coursing != 0) && (bytes(_studentFaculty).length != 0) && (_idStudent != 0) &&
        (bytes(_studentName).length != 0) && (bytes(_emailStudent).length != 0) && (_phoneStudent!=0),"Pease refill all the Student fields");
        
        new_Student.year_coursing = _year_coursing;
        new_Student.studentFaculty = _studentFaculty;
        new_Student.idStudent = _idStudent;
        new_Student.studentName = _studentName;
        new_Student.emailStudent = _emailStudent;
        new_Student.phoneStudent = _phoneStudent;
        student_Created = true;
    }

//=========================================INITIALIZING COURSE DATA============================
    function createCourse(uint _idCourse,uint _semesterTeachingCourse ,string memory _nameCourse
    ,string memory _new_examDay, string memory _new_examHour, uint _moedExam) public{
        require(student_Created == true, "Student data must to be initialized before the filling data Course.");
        require((_idCourse != 0) && (_semesterTeachingCourse != 0) && (bytes(_nameCourse).length != 0) &&
        (bytes(_new_examDay).length != 0) && (bytes(_new_examHour).length != 0) && (_moedExam != 0), "ALL the Course data must be initialized\nPlease refill all the fields");
        
        bool dateValid = date_Is_Valid(_new_examDay);
        require(dateValid, "Dear Student, please just type one of the given dates.");

        newCourse.idCourse = _idCourse;
        newCourse.semesterTeachingCourse = _semesterTeachingCourse;
        newCourse.nameCourse = _nameCourse;
        newCourse.newExamCourse = createExam(_new_examDay, _new_examHour, _moedExam);
        createdCourse = true;
    }
    function getIdCourse() public view returns(uint){
        return newCourse.idCourse;
    }
    function getSemesterTeachingCourse() public view returns(uint){
        return newCourse.semesterTeachingCourse;
    }
    function getNameCourse() public view returns(string memory){
        return newCourse.nameCourse;
    }
    function getExam()public view returns(Exam memory) {
        return newCourse.newExamCourse;
    }
    function setIdCourse(uint newIdCourse)public {
        require(newIdCourse != 0,"Please input a course number.");
        newCourse.idCourse = newIdCourse;
    }
    function setSemesterTeachingCourse(uint newSemester)public {
        require(newSemester != 0,"Please input a semester number.");
        newCourse.semesterTeachingCourse = newSemester;
    }
    function setNameCourse(string memory newNameCourse)public {
        require(bytes(newNameCourse).length != 0,"Please enter a name Exam");
        newCourse.nameCourse = newNameCourse;
    }

//=========================================INITIALIZING EXAM DATA============================
    function createExam(string memory _new_examDay, string memory _new_examHour, uint _moedExam) internal pure returns (Exam memory){
        Exam memory createdExam;
        createdExam.new_examDay = _new_examDay;
        createdExam.new_examHour = _new_examHour;
        createdExam.moedExam = _moedExam;
        return createdExam;
    }
    function getExamDay() public view returns(string memory) {
        return newCourse.newExamCourse.new_examDay;
    }
    function getExamHour()public view returns(string memory) {
        return newCourse.newExamCourse.new_examHour;
    }
    function getMoedExam()public view returns(uint){
        return newCourse.newExamCourse.moedExam;
    }
    function setExamDay(string memory _ExamDay)public {
        require(bytes(_ExamDay).length != 0,"Please enter a new Exam Day");
        newCourse.newExamCourse.new_examDay = _ExamDay;
    }
    function SetExamHour(string memory newHour) public {
        require(bytes(newHour).length != 0,"Please enter an new hour Exam");
        newCourse.newExamCourse.new_examHour = newHour;
    }
    function setMoedExam(uint _moedExam)public {
        require(_moedExam != 0,"Please input a moed Exam number.");
        newCourse.newExamCourse.moedExam = _moedExam;
    }
/////////////////////////////////////////////////////////SYSTEM FUNCTIONS////////////////////////////////////////////////////////
    function printVotingData()public view{
        console.log("Student year coursing: %s", new_Student.year_coursing);
        console.log("Student faculty: %s",new_Student.studentFaculty);
        console.log("Student id: %s",new_Student.idStudent);
        console.log("Student name: %s", new_Student.studentName);
        console.log("Student email: %s", new_Student.emailStudent);
        console.log("Student number phone: %s\n",new_Student.phoneStudent);
        console.log("The next data is the course what the student will votes:");
        console.log("Course id: %s",newCourse.idCourse);
        console.log("Taeching course semester: %s",newCourse.semesterTeachingCourse);
        console.log("Course name: %s\n",newCourse.nameCourse);
        console.log("This is the new exam date selected: ");
        console.log("Exam day: %s",newCourse.newExamCourse.new_examDay);
        console.log("Exam hour: %s", newCourse.newExamCourse.new_examHour);
        console.log("Exam moed: %s",newCourse.newExamCourse.moedExam);  
    }

    function issuing_Vote()public payable{

        require(student_Created,"Please fill the fields Student data before issue a vote.");
        require(createdCourse,"Please fill the fields Course data before issue a vote.");
        
        if(!IamReady){
            console.log("Please make sure the input data is correct before issue the vote.");
            printVotingData();
            console.log("WARNING: If the data typed its incorrect, please change it before to make the voting, otherwise push on 'I am raedy'.");     
        }
        else{
            console.log("The data to be loaded to the blockchain is:");
            printVotingData();
            students_Voted.push(msg.sender);//this line add a new voter Student in the system.
            printArray(0);//=====================================================
            require(msg.value == ethersContract);
            console.log("Thanks for voting.\nThe answer about you request will be given by the Azrieli's Administration.");
        }
    }
    function setIamReady()public {
        IamReady = true;
    }
    function date_Is_Valid(string memory date) private view returns(bool){
        uint index = 0;
        while(index < voting_Dates.length){
            if( keccak256(bytes(voting_Dates[index])) == keccak256(bytes(date)))
                return true;
            index++;
        }return false;
    } 
//=============================================SOS FUNCTIONS===================================
    function printArray(uint typeArr)public view{//typeArr = 0 prints students_Voted array, otherwise voting_Dates array
        uint index = 0;
        if(typeArr == 0){
            while(index < students_Voted.length){
            console.log("THE DATA IN ARRAY: %s",students_Voted[index]);
            index++;
            }
        }
        else{
             while(index < voting_Dates.length){
                console.log("THE DATA IN ARRAY: %s",voting_Dates[index]);
                index++;
            }
        }
       
    }
    
}

//============================================================================
/**
 * function getStudentData()public view returns(uint,string memory,uint,string memory,string memory,uint){
        return (new_Student.year_coursing,new_Student.studentFaculty,new_Student.idStudent,new_Student.studentName
        ,new_Student.emailStudent,new_Student.phoneStudent);
    }

 */