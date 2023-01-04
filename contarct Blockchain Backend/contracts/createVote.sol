// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "hardhat/console.sol";

contract createVote{

    
    struct Student{//This data will be taken from the student's account, 
        address addressStudent;
        bool hasVoted;
        bool IamReady;
        Exam newDate;//will contain the exam data
    }
    struct Exam{//This struct will contain the exam data that students will vote
        string new_examDay;
        string new_examHour;
        uint moedExam;
        bool createdExam;
    }
    struct Course{//contains the data of the course thta students are voting.
        uint idCourse;
        uint semesterTeachingCourse;
        string nameCourse;
    }
    modifier OnlyOwner{//Will allow us to call the specific functions for the owner
        require(msg.sender == owner,"Only the Administrator allowed make this action");
        _;
    }
    modifier OnlyStudent{//Will allow us to call the specific functions for the student
        require(msg.sender != owner,"Only the Student allowed make this action");
        _;
    }
//==========================================GLOBAL VARIABLES==========================================
    address owner;//will contain the owner contract address 
    Course newCourse;// This is the object Course, save all the information of the course to be voted in it.
    Student new_Student;//will contain the current student we're using in the moment.
    string[] voting_Dates;//contain the dates given by the Admin. 
    address[] adresssesStudents;//lo lasot=======================================================
    mapping(address => bool) studentsHasVoted;//tell us if X student has vote already.
    mapping (string =>uint) votes;//contains the counters voting for every date
    mapping(address => Student) studentsAtSystem;//save the students existents in the system.

    uint dateExpiringContract;//contains the date when the contract expires
    uint dateCreatedContract;//contains the date when the contract is created
    

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
        //initializing the course data to be voted
        newCourse.idCourse = _idCourse;
        newCourse.nameCourse = _nameCourse;
        newCourse.semesterTeachingCourse = _semesterTeachingCourse;
        //initializing the expiration contract
        dateCreatedContract = block.timestamp;
        dateExpiringContract = dateCreatedContract + 15 minutes;

    }//["2/22/34","5/22/34","9/22/34"], 100102, 2, hedva2
    //2/22/34, 15, 2
    //5/22/34, 18, 3
    //9/22/34, 11, 1

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
    function create_Student() public OnlyStudent{//This is the constructor Student.
        //checking the expiration contract
        require(!timeForVotingIsOver(),"SORRY, The time for voting it's over. Please contact with the Administrator Exams");
        //checking if the data student has bee initialized by the system
        require(!studentAlreadyCreated(msg.sender), "The student exist already at the system.");
        
        Student memory newStud;//creating a student to be saved after in the data structure where all the students are saved.
        //initializing the data of the new student
        newStud.addressStudent = msg.sender;
        newStud.hasVoted = false;
        newStud.IamReady = false;
        studentsHasVoted[msg.sender] = false;
        
        //updating the data Structures
        studentsAtSystem[msg.sender] = newStud;
        adresssesStudents.push(msg.sender);
        new_Student = newStud;
    }

    function studentAlreadyCreated(address searching) private view returns(bool){//the function get as parameter an address user
    //and returns true if the student data has been creared, otherwise false. 
        uint indx = 0;
        while(indx < adresssesStudents.length){
            if(adresssesStudents[indx] == searching)
                return true;
            indx ++;
        }
        return false;
    }
     
    function printStudentsAtSystem() public view{//============================================
    //printes the data of every student created in our system Blockchain
        uint counter = 0;
        Student memory curr;
        while(counter < adresssesStudents.length){
            curr = studentsAtSystem[adresssesStudents[counter]];
            console.log("The student Address is: %s", curr.addressStudent);
            console.log("The student has voted: %s", curr.hasVoted);
            console.log("The student ready to vote: %s", curr.IamReady);
            console.log("The Exam has been created? : %s", curr.newDate.createdExam);
            console.log("Day selected by the student: ", curr.newDate.new_examDay);
            console.log("Hour selected by the student: ", curr.newDate.new_examHour);
            console.log("Moed selected by the student: ", curr.newDate.moedExam);
            counter ++;
        }
    }

//=========================================INITIALIZING EXAM DATA============================
    function createExam(string memory _new_examDay, string memory _new_examHour, uint _moedExam) public OnlyStudent{//This is the constructor Exam, just the student allowed call this function. 
    //the function get the data of the new date wich the the student wants to change.
        
        //checking the expiration contract
        require(!timeForVotingIsOver(),"SORRY, The time for voting it's over. Please contact with the Administrator Exams");
        //checking if the student that calls this function has been created in the system
        require(studentAlreadyCreated(msg.sender), "The student no exist yet, is not posible continue without the student data.");
        //checking if the students that calls this function has issue a vote already
        require(!studentVoted(msg.sender),"Sorry the vote can't be issued because the student has voted already.");
        //cheking if the enter data as parameters is not empety in every field of the system 
        require((bytes(_new_examDay).length != 0) && (bytes(_new_examHour).length != 0) && (_moedExam != 0), "ALL the Course data must be initialized\nPlease refill all the fields");
        //this require checks that just we can call the function once, after we just can edit the information exam typed 
        require(!studentsAtSystem[msg.sender].newDate.createdExam,"Not posible recreate the Exam data, just possible to edit it.");
        bool dateValid = date_Is_Valid(_new_examDay);//checking id the put in date is correct, saves true if is correct, otherwise false
        //checks if the date is correct
        require(dateValid, "Dear Student, please just type one of the given dates in the same format, otherwise you will not be able to issue a vote.");
        new_Student = studentsAtSystem[msg.sender];//gets the student saved   with the current address

        //filling the Exam data.
        new_Student.newDate.new_examDay = _new_examDay;
        new_Student.newDate.new_examHour = _new_examHour;
        new_Student.newDate.moedExam = _moedExam;
        new_Student.newDate.createdExam = true; 
        studentsAtSystem[msg.sender] = new_Student; 
    }
    ////////////////////////////////////////////GETTERS AND SETTERS///////////////////////////
    function getStudentAddress()public view returns(address){
        return studentsAtSystem[msg.sender].addressStudent;
    }
    function getHasVoted()public view returns(bool) {
        return studentsAtSystem[msg.sender].hasVoted;
    }
    function getExamDay() public view returns(string memory) {
        return studentsAtSystem[msg.sender].newDate.new_examDay;
    }
    function getExamHour()public view returns(string memory) {
        return studentsAtSystem[msg.sender].newDate.new_examHour;
    }
    function getMoedExam()public view returns(uint){
        return studentsAtSystem[msg.sender].newDate.moedExam;
    }
    function setExamDay(string memory _ExamDay)public {
        //checking expiration contract
        require(!timeForVotingIsOver(),"SORRY, The time for voting it's over. Please contact with the Administrator Exams");
        require(!studentVoted(msg.sender),"Sorry the vote can't be issued because the student has voted already.");
        require(bytes(_ExamDay).length != 0,"Please enter a new Exam Day");
        bool dateValid = date_Is_Valid(_ExamDay);//checking id the put in date is correct
        require(dateValid, "Dear Student, please just type one of the given dates in the same format, otherwise you will not be able to issue a vote.");

        studentsAtSystem[msg.sender].newDate.new_examDay = _ExamDay;
    }
    function SetExamHour(string memory newHour) public {
        //checking expiration contract
        require(!timeForVotingIsOver(),"SORRY, The time for voting it's over. Please contact with the Administrator Exams");
        require(!studentVoted(msg.sender),"Sorry the vote can't be issued because the student has voted already.");
        require(bytes(newHour).length != 0,"Please enter an new hour Exam");
        studentsAtSystem[msg.sender].newDate.new_examHour = newHour;
    }
    function setMoedExam(uint _moedExam)public {
        //checking expiration contract
        require(!timeForVotingIsOver(),"SORRY, The time for voting it's over. Please contact with the Administrator Exams");
        require(!studentVoted(msg.sender),"Sorry the vote can't be issued because the student has voted already.");
        require(_moedExam != 0,"Please input a moed Exam number.");
        studentsAtSystem[msg.sender].newDate.moedExam = _moedExam;
    }

    function setHasVoted() private {//change the student status "hasVoted" when he issue the vote
        studentsAtSystem[msg.sender].hasVoted = true;
    }
    
    function setIamReady() public {//if the student is ready to issue a vote we set to is ready.
        studentsAtSystem[msg.sender].IamReady = true;
    }

/////////////////////////////////////////////////////////ISSUING THE VOTE////////////////////////////////////////////////////////
    
    function issuing_Vote() public OnlyStudent{//this function make the vote. Just the student can to call this function.
        //checking expiration contract
        require(!timeForVotingIsOver(),"SORRY, The time for voting it's over. Please contact with the Administrator Exams");
        new_Student = studentsAtSystem[msg.sender];
        //checking if the student has issue a vote 
        require(!new_Student.hasVoted,"Sorry the vote can't be issued because the student has voted already.");
        //checking if the data Exam has been initialized
        require(new_Student.newDate.createdExam,"Please indicate what is your preferent date to change the Exam before issue a vote.");
        
        if(!new_Student.IamReady){//before to make the vote, we make sure that the input data is rigth.
            console.log("Please make sure the input data is correct before issue the vote.");
            printVotingData();
            console.log("WARNING: If the data typed its incorrect, please change it before to make the voting, otherwise push on 'I am raedy'.");     
        }
        else{//After we are sure that the data is right so we can issue the vote.
            console.log("The data to be loaded to the blockchain is:");
            printVotingData();//we print the final data
            votes[getExamDay()] +=1;//adding a new voter to the voted date.
            setHasVoted();//changing the status student to "the studen has voted == true"  
            studentsHasVoted[new_Student.addressStudent] = true;//adding the student status "hasVoted" to the mapping according his address
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
    function printVotingData()public{//print the put in data by the student for issue the vote, this data
    //will be sent to the blockchain
        console.log("The course you are voting for it is:");
        console.log("Course id: %s",newCourse.idCourse);
        console.log("Course name: %s\n",newCourse.nameCourse);
        console.log("Teaching course semester: %s",newCourse.semesterTeachingCourse);
        console.log("The new exam date that you selected: ");
        new_Student = studentsAtSystem[msg.sender];
        console.log("Exam day: %s",new_Student.newDate.new_examDay);
        console.log("Exam hour: %s", new_Student.newDate.new_examHour);
        console.log("Exam moed: %s",new_Student.newDate.moedExam);  
    }

    function studentVoted(address currStudent) private view returns(bool) {//returns if the student
    //whose active this function has voted already or not
        return studentsHasVoted[currStudent];
    }

//=============================================SOS FUNCTIONS===================================
    
    function printArrayStudentsVoted()public view OnlyOwner{//prints how many voters voted to every date 
    //this function just can be called for the Administrator.
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