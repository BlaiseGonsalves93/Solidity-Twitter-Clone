// SPDX-License-Identifier: MIT
import "@openzeppelin/contracts/access/Ownable.sol";

pragma solidity ^0.8.1;

interface IProfile {
    struct UserProfile {
        string displayName;
        string bio;
    }
    
    // CODE HERE
    function getProfile(address _user) external  view returns (UserProfile memory);
}

contract Twitter is Ownable {
    uint16 public  MAX_TWEET_LENGTH = 280;
 

    //define tweet struct
    struct Tweet {
        uint256 id;
        address author;
        string content;
        uint256 timestamp;
        uint256 likes;
    }
    
    //mapping address to array of tweets
    mapping(address => Tweet[]) public tweets;
    IProfile profileContract;

    modifier onlyRegistered(){
        IProfile.UserProfile memory userProfileTemp = profileContract.getProfile(msg.sender);
        require(bytes(userProfileTemp.displayName).length > 0, "USER NOT REGISTERED");
        _;
    }
    

    constructor(address _profileContract)Ownable(msg.sender) {
        // Initialize the profile contract instance
        profileContract = IProfile(_profileContract);

        profileContract = IProfile(_profileContract);
    }


    event TweetCreated( uint256 id, address author, string content, uint256 timestamp); 
    event TweetLiked(address liker, address tweetauthor, uint256 tweetId, uint256 newlikecount); 
    event TweetUnliked(address unliker,address tweetauthor, uint256 tweetId, uint256 newlikecount);   
  
 

    function changetweetlength(uint16 newtweetlength) public onlyOwner{
        MAX_TWEET_LENGTH = newtweetlength;
    }

    function getTotalLikes(address _author) external  view returns (uint){
        uint TotalLikes;

        for(uint i=0; i< tweets[_author].length; i++){
            TotalLikes += tweets[_author][i].likes;
        }
        return TotalLikes;
    }

    //function to create a tweet and store it in “tweets variable”
    function createTweet (string memory _tweetContent) public onlyRegistered {
        
        require(bytes(_tweetContent).length<= MAX_TWEET_LENGTH, "Maximum 280 characters" );

        Tweet memory newTweet = Tweet({
            id: tweets[msg.sender].length,
            author:  msg.sender,
            content: _tweetContent,
            timestamp: block.timestamp,
            likes: 0
        });
        
        tweets[msg.sender].push(newTweet);
        emit TweetCreated(newTweet.id, newTweet.author, newTweet.content, newTweet.timestamp);
    }

        function likeTweet(address author, uint256 id) external onlyRegistered {
        require(id < tweets[author].length, "Tweet does not exist.");
        tweets[author][id].likes++;

        emit TweetLiked(msg.sender, author, id, tweets[author][id].likes);
    }
    /*
    function liketweet(address author, uint256 id) external{
        require(Tweet[author][id].id == id, "Tweet does not exist");
        Tweet[author][id].like++;
    }
    */
    function unliketweet(address author, uint256 id) external onlyRegistered {
        require(id < tweets[author].length, "Tweet does not exist");
         require(tweets[author][id].likes > 0, "No likes to remove.");
        tweets[author][id].likes--;

        emit TweetUnliked(msg.sender, author, id, tweets[author][id].likes);
    }
    
    function getTweet ( uint _i) public view returns (Tweet memory) {
        return tweets[msg.sender][_i];
    }
  
    function getALLtweets (address _owner) public view returns (Tweet[] memory){
        return tweets[_owner];
    }
}