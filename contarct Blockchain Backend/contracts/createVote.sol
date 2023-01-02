// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "hardhat/console.sol";

contract createVote{

    
    struct Student{//This data will be taken from the student's account, 
        address addressStudent;
        bool hasVoted;
        bool IamReady;
    }
    struct Exam{//This struct will contain the exam data that students will vote
        string new_examDay;
        string new_examHour;
        uint moedExam;
        bool createdExam;
        Student new_Student;
    }
    struct Course{//contains the data of the course thta students are voting.
        uint idCourse;
        uint semesterTeachingCourse;
        string nameCourse;
    }
    modifier OnlyOwner{
        require(msg.sender == owner,"Only the Administrator allowed make this action");
        _;
    }
    modifier OnlyStudent{
        require(msg.sender != owner,"Only the Student allowed make this action");
        _;
    }
//==========================================GLOBAL VARIABLES==========================================
    address owner;
    Course newCourse;// This is the object Course, save all the information of the course to be voted in it.
    Exam newDate;//will contain the exam data
    string[] voting_Dates;//contain the dates given by the Admin. 
    //address[] studentsHasVoted;//lo lasot
    mapping(address => bool) studentsHasVoted;//tell us if X student has vote already.
    mapping (string =>uint) votes;//contains the counters voting for every date
    uint dateExpiringContract;
    uint dateCreatedContract;
    

//=======================================================CONSTRUCTOR========================================================
//The constructor will initialize the data of the course that we select to be voted 
    constructor(string[] memory dates, uint _idCourse, uint _semesterTeachingCourse, string memory _nameCourse){//THIS IS THE CONSTRUCTOR, the ADMIN give the data
        require((_idCourse != 0) && (_semesterTeachingCourse != 0) && (bytes(_nameCourse).length != 0), "Please fill all the fields");
        owner = msg.sender;
        uint num_dates = 0;
        while(num_dates < dates.length){//This loop put the dates in the array "voting_Dates"
            voting_Dates.push(dates[num_dates]);//coping the input dates to the array dates 
            votes[dates[num_dates]] = 0;//creating the map that will save the votes to the different dates
            num_dates++;
        }
        newCourse.idCourse = _idCourse;
        newCourse.nameCourse = _nameCourse;
        newCourse.semesterTeachingCourse = _semesterTeachingCourse;
        dateCreatedContract = block.timestamp;
        dateExpiringContract = dateCreatedContract + 5 minutes;

    }//["2/22/34","5/22/34","9/22/34"] 100102 hedva2 2

    function getAvaleableDates()public view{//If the student wants to see the available dates 
        uint index = 0;
        console.log("The available dates are:");
        while(index < voting_Dates.length){
            console.log(voting_Dates[index]);
            index++;
        }
    }

    function printDataCourse() public view {//this function prints the course to be voted 
        console.log("The course that you are voting is:");
        console.log("Name course: %s",newCourse.nameCourse);
        console.log("Id course: %s", newCourse.idCourse);
        console.log("Teached in the semester: %s",newCourse.semesterTeachingCourse);
    }

    function timeForVotingIsOver() private view returns (bool) {//This function tell us if the voting date has finished returning true, otherwise returns false
        if(block.timestamp > dateExpiringContract)
            return true;
        return false;
    }


//=========================================INITIALIZING STUDENT DATA============================
//The data will be gotten from the account Usuary 
    function createStudent() private OnlyStudent{//This is the constructor Student.
        //Checking if all the data was enter, if not will get an error. 
        //The usuary must to have in his account all the next data: 
        newDate.new_Student.addressStudent = msg.sender;
        newDate.new_Student.hasVoted = false;
        newDate.new_Student.IamReady = false;
        studentsHasVoted[msg.sender] = false;
    }

//=========================================INITIALIZING EXAM DATA============================
    function createExam(string memory _new_examDay, string memory _new_examHour, uint _moedExam) public OnlyStudent{//This is the constructor Exam, just the student allowed call this function. 
        require(!timeForVotingIsOver(),"SORRY, The time for voting it's over. Please contact with the Administrator Exams");
        require(!studentVoted(msg.sender),"Sorry the vote can't be issued because the student has voted already.");
        require((bytes(_new_examDay).length != 0) && (bytes(_new_examHour).length != 0) && (_moedExam != 0), "ALL the Course data must be initialized\nPlease refill all the fields");
        bool dateValid = date_Is_Valid(_new_examDay);//checking id the put in date is correct
        require(dateValid, "Dear Student, please just type one of the given dates in the same format, otherwise you will not be able to issue a vote.");
        newDate.createdExam = true;
        
        createStudent();//creating the object student
        //filling the Exam data.
        newDate.new_examDay = _new_examDay;
        newDate.new_examHour = _new_examHour;
        newDate.moedExam = _moedExam;
    }
    function getStudentAddress()public view returns(address){
        return newDate.new_Student.addressStudent;
    }
    function getHasVoted()public view returns(bool) {
        return newDate.new_Student.hasVoted;
    }
    function getExamDay() public view returns(string memory) {
        return newDate.new_examDay;
    }
    function getExamHour()public view returns(string memory) {
        return newDate.new_examHour;
    }
    function getMoedExam()public view returns(uint){
        return newDate.moedExam;
    }
    function setExamDay(string memory _ExamDay)public {
        require(!timeForVotingIsOver(),"SORRY, The time for voting it's over. Please contact with the Administrator Exams");
        require(!studentVoted(msg.sender),"Sorry the vote can't be issued because the student has voted already.");
        require(bytes(_ExamDay).length != 0,"Please enter a new Exam Day");
        bool dateValid = date_Is_Valid(_ExamDay);//checking id the put in date is correct
        require(dateValid, "Dear Student, please just type one of the given dates in the same format, otherwise you will not be able to issue a vote.");

        newDate.new_examDay = _ExamDay;
    }
    function SetExamHour(string memory newHour) public {
        require(!timeForVotingIsOver(),"SORRY, The time for voting it's over. Please contact with the Administrator Exams");
        require(!studentVoted(msg.sender),"Sorry the vote can't be issued because the student has voted already.");
        require(bytes(newHour).length != 0,"Please enter an new hour Exam");
        newDate.new_examHour = newHour;
    }
    function setMoedExam(uint _moedExam)public {
        require(!timeForVotingIsOver(),"SORRY, The time for voting it's over. Please contact with the Administrator Exams");
        require(!studentVoted(msg.sender),"Sorry the vote can't be issued because the student has voted already.");
        require(_moedExam != 0,"Please input a moed Exam number.");
        newDate.moedExam = _moedExam;
    }
    function setHasVoted() private {//tell us if the student made a vote already
        newDate.new_Student.hasVoted = true;
    }
    
    function setIamReady() public {//if the student is ready to issue a vote we set to is ready.
        newDate.new_Student.IamReady = true;
    }

/////////////////////////////////////////////////////////ISSUING THE VOTE////////////////////////////////////////////////////////
    
    function issuing_Vote() public OnlyStudent{//this function make the vote. Just the student can to call this function.
        
        require(!timeForVotingIsOver(),"SORRY, The time for voting it's over. Please contact with the Administrator Exams");
        require(!newDate.new_Student.hasVoted,"Sorry the vote can't be issued because the student has voted already.");
        require(newDate.createdExam,"Please indicate what is your preferent date to change the Exam before issue a vote.");
        
        if(!newDate.new_Student.IamReady){//before to make the vote, we make sure that the input data is rigth.
            console.log("Please make sure the input data is correct before issue the vote.");
            printVotingData();
            console.log("WARNING: If the data typed its incorrect, please change it before to make the voting, otherwise push on 'I am raedy'.");     
        }
        else{//After we are sure that the data is right so we can issue the vote.
            console.log("The data to be loaded to the blockchain is:");
            printVotingData();//we print the final data
            votes[this.getExamDay()] +=1;//adding a new voter to the voted date.
            setHasVoted();
            studentsHasVoted[newDate.new_Student.addressStudent] = true;
            console.log("Thanks for voting.\nThe answer about you request will be given by the Azrieli's Administration.");
        }
    }

    function date_Is_Valid(string memory date) private view returns(bool){//returns true if the date put in
    //by the student is correct (is one among the dates given by the ADMIN), otherwise returns false
        uint index = 0;
        while(index < voting_Dates.length){
            if( keccak256(bytes(voting_Dates[index])) == keccak256(bytes(date)))
                return true;
            index++;
        }return false;
    } 
//
    function printVotingData()public view{//print the data put in for issue the vote
        console.log("The course you are voting for it is:");
        console.log("Course id: %s",newCourse.idCourse);
        console.log("Course name: %s\n",newCourse.nameCourse);
        console.log("Teaching course semester: %s",newCourse.semesterTeachingCourse);
        console.log("The new exam date that you selected: ");
        console.log("Exam day: %s",newDate.new_examDay);
        console.log("Exam hour: %s", newDate.new_examHour);
        console.log("Exam moed: %s",newDate.moedExam);  
    }

    function studentVoted(address currStudent) private view returns(bool) {
        return studentsHasVoted[currStudent];
    }

//=============================================SOS FUNCTIONS===================================
    
    function printArrayStudentsVoted()public view OnlyOwner{//prints how many voters voted to every date 
        uint index = 0;
        while(index < voting_Dates.length){
            console.log("THE DATE IS: %s",voting_Dates[index]);
            console.log("AND THE NUMBER STUDENTS VOTED TO THIS DATE: %s",votes[voting_Dates[index]]);
            index++;
            
        }
    }
}

//============================================================================
/**
 * function getStudentData()public view returns(uint,string memory,uint,string memory,string memory,uint){
        return (new_Student.year_coursing,new_Student.studentFaculty,new_Student.idStudent,new_Student.studentName
        ,new_Student.emailStudent,new_Student.phoneStudent);
    }

    function timestampToDateTime(uint timestamp) public pure returns (uint year, uint month, uint day, uint hour, uint minute, uint second)
https://github.com/RollaProject/solidity-datetime#timestamptodatetime
    

 */