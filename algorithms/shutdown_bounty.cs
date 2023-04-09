/**
 *	Shutdown Bounty logic in v10.02.5 
 *	Detailed explanation here: https://github.com/LegionTD2-Modding/.github/wiki/Details-on-game-logic#shutdown-bounty
 **/
public static int GetShutdownBounty(ushort player, Dictionary<ushort, float> powerScores)
{
	// Return value
	int playerBounty = 0;

	// Get all needed data
	float avgPowerScore_teamLeft = 0.0;
	float avgPowerScore_teamRight = 0.0;
	int teamLeft_numUsers = 0;
	
	for (ushort user_id = 1; user_id <= 4; user_id += 1)
	{
		if (powerScores.ContainsKey(user_id))
		{
			avgPowerScore_teamLeft += powerScores[user_id];
			teamLeft_numUsers++;
		}
	}
	
	if (teamLeft_numUsers > 0)
	{
		avgPowerScore_teamLeft /= (float)teamLeft_numUsers;
	}
	
	int teamRight_numUsers = 0;
	for (ushort user_id = 5; user_id <= 8; user_id += 1)
	{
		if (powerScores.ContainsKey(user_id))
		{
			avgPowerScore_teamRight += powerScores[user_id];
			teamRight_numUsers++;
		}
	}
	
	if (teamRight_numUsers > 0)
	{
		avgPowerScore_teamRight /= (float)teamRight_numUsers;
	}

	if (teamLeft_numUsers == 0 || teamRight_numUsers == 0)
	{
		return (playerBounty = 0);
	}
	

	float teamsDiffAvgPowerScore = avgPowerScore_teamLeft - avgPowerScore_teamRight;
	bool playerIsFromLeftTeam = PlayerApi.IsPlayerAlly(player, 1);
	bool teamLeftIsAhead = avgPowerScore_teamLeft >= avgPowerScore_teamRight;
	
	List<ushort> usersInTeamAhead =
			teamLeftIsAhead ? new List<ushort>{1, 2, 3, 4} : new List<ushort>{5, 6, 7, 8};
	
	int teamAhead_numUsers = (teamLeftIsAhead ? teamLeft_numUsers : teamRight_numUsers);
	float aheadTeamPowerScore = (teamLeftIsAhead ? avgPowerScore_teamLeft : avgPowerScore_teamRight);
	float behindTeamPowerScore = (teamLeftIsAhead ? avgPowerScore_teamRight : avgPowerScore_teamLeft);
	
	if ((playerIsFromLeftTeam && !teamLeftIsAhead) || (!playerIsFromLeftTeam && teamLeftIsAhead)) {
		return (playerBounty = 0);
	}

	// Actual algorithm
	float absoluteAvgPowerScoreDifference = Math.Abs(teamsDiffAvgPowerScore);
	float bountyAmount = (absoluteAvgPowerScoreDifference / 6.0) * teamAhead_numUsers;

	Dictionary<ushort, float> powerscoreAboveAvgLosingTeam =
			new Dictionary<ushort, float>();
	
	foreach (ushort user_id in usersInTeamAhead)
	{
		if (!powerScores.ContainsKey(user_id))
		{
			powerscoreAboveAvgLosingTeam[user_id] = 0.0;
		}
		else
		{
			powerscoreAboveAvgLosingTeam[user_id] = powerScores[user_id] - behindTeamPowerScore;
			if (powerscoreAboveAvgLosingTeam[user_id] < 0.0)
			{
				powerscoreAboveAvgLosingTeam[user_id] = 0.0;
			}
		}
	}
	
	float totalPowerscoreAboveAvgLosingTeam = powerscoreAboveAvgLosingTeam.Values.Sum();
	if (totalPowerscoreAboveAvgLosingTeam == 0.0)
	{
		return (playerBounty = 0);
	}

	float finalWeight = bountyAmount / totalPowerscoreAboveAvgLosingTeam;
	float rawResult = powerscoreAboveAvgLosingTeam[player] * finalWeight;
	int resultRoundedToFloor25 = (25 * (int)(Math.Floor(rawResult / 25.0)));

	return (playerBounty = resultRoundedToFloor25);
}
