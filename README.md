# Wec Recruitment Blockchain Task

This is written in the solidity language and tested using the Remix IDE. 
Implemented a blockchain-based election using smart contract.

This election has various features to conduct an election with utmost security.
The features of this election are:

1. Admin sets the duration for voting.
2. Multiple elections can happen for different posts at the same time.
3. Every candidate can contest/apply for the posts for different elections based on criteria given by admin.
4. Voters can vote once in each election.
5. Every user can view the candidate that has won the election after it has been concluded.

Functions used:

1. candidate_apply(): Candidates have to apply using this external function with their address. This helps the candidate to give an entry for the post he is applying for. Further, he is also added to the list of candidates contesting for that particular post.
2. add_organiser(): This function adds an organiser to the org_map using its address.
3. assign_org(): The admin has the power to assign an organisation.
4. accept_candidate(): The admin accepts the candidate after looking at his application.
5. reject_candidate(): The admin rejects the candidate after looking at his application. 
6. vote(): Here, the voters have the ability to vote for a preferred candidate.
7. post_winner(): Displays the winner of a post after election has been concluded.
