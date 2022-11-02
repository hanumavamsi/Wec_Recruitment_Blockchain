// SPDX-License-Identifier: MIT
pragma solidity >= 0.7.0<0.9.0;

contract election{
    // start time and duration of the election 

        uint public startTime;
        uint public duration;

    // address of the admin will  be stored here 
    // The address who deploys this will be assigned with the admin role  
    address public admin;
    // The organiser struct, used for the mainting the addresses, and their power to accept or reject votes
    struct Organiser{
        address org_add;
        bytes32 name;
        bool orgPower;
    }


    // These are the posts which will be added by the admin in the constructor itself
    // postCount maintains the number of posts open for election
    bytes32[] public posts;
    uint public postCount;
    mapping(uint => address[]) voting_map;

    //The Candidate struct has a lot of parameters just like a real life application 
    // address cAdress is used for maintaining the address of a candidate
    // post_contesting for is used for the candidate to apply for the post he would like to contest for
    // voteCount and candidatePower are the 2 maps inside the candidate struct which keep the 
    // the track of whether the candidate has the power to stand for election and if he does 
    // the amount of votes he got for it 
    struct Candidate{
        address cAdress;
        uint post_contesting_for;
        bytes32 name;
        uint roll_number;
        bytes32 date_of_birth;
        uint gpa;
        mapping(uint => uint) voteCount;
        mapping(uint => bool) candidatePower;
        bool applied;
    }
    // Voter struct is for the users to vote and it also stores whether the Voter has 
    // already voted or not
    struct Voter{
        bytes32 name;
        uint candidate_id;
        mapping(uint => bool) elig_to_vote;
        mapping(uint => bool) voted;   
    }
    // this is the vote map which keeps track of the voters 
    mapping(address => Voter) public vote_map;

    // Since the candidates and orgs are stored in a map, we don't know the number of people applying for it
    // hence this counts help us to know the number of candidates / organisers
    uint public candidateCount=0;
    uint public orgCount=0;

    //modifiers 
    
    // This modifier is used for onlyAdmin processes like assigning org .. configuring electioins etc
    modifier onlyAdmin{
        require(msg.sender == admin,'Only admin can access');
        _;
    }

    // This modifier is used for admin and also the organiser
    modifier onlyOrgOrAdmin{
        require(msg.sender == admin || org_map[msg.sender].org_add == msg.sender,'Only Admin or Org can access ');
        require(msg.sender == admin || org_map[msg.sender].orgPower == true,'The org must have power');
        _;
    }

    modifier end{
        require(block.timestamp < startTime + (duration*1 minutes),'Election duration has been completed');
        _;
    }

    modifier start{
        require(block.timestamp > startTime,'Election has not been started yet');
        _;
    }

    //events 
    // This event accounts for the votes by the voters
    event voting_event(address indexed from, address indexed to,uint post);

    // mapping of candidates
    mapping(address => Candidate) public cand_map;
    // mapping of organisers
    mapping(address => Organiser) public org_map;

    // Constructor 
    // constructor will include admin == msg.sender
    // constructor will take in the posts as well
    constructor(bytes32[] memory _postNames,uint _startTime,uint _duration) {
        admin = msg.sender;
        postCount = _postNames.length;
        for(uint i=0;i<postCount;i++){
            posts.push(_postNames[i]);
        }
        startTime = _startTime;
        duration = _duration;
    }

    // Candidates have to apply using this external function with their address
    // This helps the candidate to give an entry for the post he is applying for
    // Further, he is also added to the list of candidates contesting for that particular post
    function candidate_apply
    (
        uint _post_contesting_for,
        bytes32 _name,
        uint _roll_number,
        bytes32 _date_of_birth,
        uint _gpa
    ) 
        public
    {
        require(cand_map[msg.sender].applied == false, 'The candidate has already applied');
        cand_map[msg.sender].cAdress = msg.sender;
        cand_map[msg.sender].post_contesting_for = _post_contesting_for;
        cand_map[msg.sender].name= _name;
        cand_map[msg.sender].roll_number= _roll_number;
        cand_map[msg.sender].date_of_birth= _date_of_birth;
        cand_map[msg.sender].gpa= _gpa;
        // cand_map[msg.sender].voteCount=0;
        cand_map[msg.sender].applied=true;
        // cand_map[msg.sender].candidatePower=[false,false,false];
        for(uint i=0;i<postCount;i++){
            cand_map[msg.sender].candidatePower[i]=false;
            cand_map[msg.sender].voteCount[i] = 0;
        }
        voting_map[_post_contesting_for].push(msg.sender);
        candidateCount += 1;
    }

    // This function adds an organiser to the org_map using its address
    function add_organiser 
    (
        address _org_add,
        bytes32 _name
    )
        public
    {
        org_map[_org_add].org_add = _org_add;
        org_map[_org_add].name = _name;
        org_map[_org_add].orgPower = false;
        orgCount += 1;
    }

    // This function is only accessed by the admin
    // The admin assigns or gives power to the organiser for accepting or rejecting votes
    function assign_org(
        address _org_address
    )
        public
        onlyAdmin
    {
        require(org_map[_org_address].org_add == _org_address,'The Organiser has not applied');
        org_map[_org_address].orgPower = true;
    }

    // This function is also accessed by the admin only
    // This function accepts a particular candidate for contending in the respective post
    function accept_candidate(
        address _cand_add, uint _post_applying_for
    )
        public 
        onlyAdmin
    {
        require(cand_map[_cand_add].applied == true,'The Candidate has not applied');
        cand_map[_cand_add].candidatePower[_post_applying_for] = true;
    }

    // This function is also accessed by the admin only
    // This function rejects a particular candidate for contending in the respective post
    function reject_candidate(
        address _cand_add, uint _post_applying_for
    )
        public 
        onlyAdmin
    {
        require(cand_map[_cand_add].applied == true,'The Candidate has not applied');
        require(cand_map[_cand_add].candidatePower[_post_applying_for] == false,'The candidate has already been rejected');
        cand_map[_cand_add].candidatePower[_post_applying_for] = false;
    }

    // // This function can be accessed by the admin or organiser only
    // // It is used to give the eligibility to vote for a particular voter
    // function give_eligibility(
    //     address _gv,
    //     uint _post
    // )
    //     public
    //     onlyOrgOrAdmin
    // {
    //     vote_map[_gv].elig_to_vote[_post] = true;
    // }

    // This function is used by the voters to vote for their favourite candidate
    function vote(
        uint _vote_post,uint _vote_candidate 
    )
        public
        start
        end
    {
        // require(vote_map[msg.sender].elig_to_vote[_vote_post] == false,'No eligibility for the voter');
        require(vote_map[msg.sender].voted[_vote_post] == false,'The voter has already voted');
        require(_vote_post < postCount, 'Existing post does not exist');
        require(cand_map[voting_map[_vote_post][_vote_candidate]].candidatePower[_vote_post] == true,'The candidate isnt eligible');
        cand_map[voting_map[_vote_post][_vote_candidate]].voteCount[_vote_post]++;
        vote_map[msg.sender].voted[_vote_post] == true;
        emit voting_event(msg.sender,voting_map[_vote_post][_vote_candidate],_vote_post);
    }   


    // This function is an internal function used for getting the address of the winning
    // for a particular post
    function post_win_add(
        uint _post
    )
        internal
        view
        returns(address winningCandAddress_)
    {
        require(_post < postCount, 'Post does not exist');
        uint max = 0;
        for(uint i=0;i<voting_map[_post].length;i++){
            if(cand_map[voting_map[_post][i]].voteCount[_post] > max){
                max = cand_map[voting_map[_post][i]].voteCount[_post];
                winningCandAddress_ = voting_map[_post][i];
            }
        }
        return winningCandAddress_;
    }

    // post_winner can be accessed by anyone
    // It diaplays the candidate who won amongst his contenders with the highest number of votes
    function post_winner(
        uint _post
    )
        public
        view
        returns(bytes32 winnerName_)
    {
        winnerName_ = cand_map[post_win_add(_post)].name;
        return winnerName_;
    }    

}