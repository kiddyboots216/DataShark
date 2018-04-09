pragma solidity 0.4.21;


contract Query {

    uint public vectorLength;
    uint public totalNumData = 0;
    uint public numberOfResponses = 0;
    bool public moreThanOne = false;
    uint public maxRounds;
    uint public modelType;
    uint public goalAccuracy;
    uint public numClients;
    uint public currentRound;
    
    int[] currentWeights;
    
    address[] public keyList;
    mapping(int => int[]) public weights;

    /////////////
    // Structs //
    /////////////

    ///////////////
    // Modifiers //
    ///////////////

    //////////////
    //  Events  //
    //////////////

    event ClientSelected(address client, int[] initialWeights);
    event ResponseReceived(uint n);
    // event FederatedAveragingComplete();

    ///////////////
    // Functions //
    ///////////////

    function Query(int _vectorLength, address[] _keyList,
        int _goalAccuracy, int _modelType, int _maxRounds,
        int[] _initialWeights, int _numClients
        ) public {
        goalAccuracy = uint(_goalAccuracy);
        modelType = uint(_modelType);
        maxRounds = uint(_maxRounds);
        vectorLength = uint(_vectorLength);
        numClients = uint(_numClients);
        keyList = _keyList;
        uint keyLength = keyList.length;
        currentWeights = _initialWeights;
        // for (uint i = 0; i < keyLength; i++) {
        //     weights[keyList[i]] = new int[](keyLength);
        // }
    }

    function pingClients(address[] clientList) internal {
        uint clientLen = clientList.length;
        for (uint i = 0; i < clientLen; i++) {
            emit ClientSelected(clientList[i], currentWeights);
        }
        currentWeights = new int[](vectorLength);
    }
    
    function receiveResponse(
        int[] _clientUpdate,
        // address _clientAddress,
        int _numData) 
        public 
        {
            //TODO: make sure that only a client who is SUPPOSED to be training can call this!
            //received client update has already been multiplied by _numData
            //so we just need to divide it by our total data
            //scaling client update by n_k/n
            uint numData = uint(_numData);
            totalNumData = totalNumData + numData;
            uint i;
            int[] memory newUpdate = new int[](vectorLength);
            for (i = 0; i < vectorLength; i ++) {
                newUpdate[i] =  divide(_clientUpdate[i], _numData);
            }
            //adding the new client update to the current ones 
            //TODO: is this parallelism?
            for (i = 0; i < vectorLength; i ++) {
                currentWeights[i] = currentWeights[i] + newUpdate[i];
            }
            numberOfResponses ++;
            //if this was the last client we needed to hear from, go ahead and 
            //start another round of training if we haven't exceeded our max rounds
            if (numberOfResponses > numClients) {
                if (currentRound < maxRounds) {
                    pingClients(keyList);
                }
                currentRound ++;
            }
            //now transfer some ETH to the client as thanks for training our model!
            //for now the heuristic is just how much data they had
            //TODO: get the address from the client that sent in their response
            // _clientAddress.transfer(numData);
        }
    
    function divide(int i, int j) returns (int k) {
        //TODO: Implement real division lmao
        return i / k;
    }
    
    function sendResponse(
        int[] update,
        int key,
        int numData)
        external
        returns (int[])
        // needs permissioning
    {
        uint i;
        uint keyLen = keyList.length;
        if (moreThanOne) {
            int[] memory newUpdate = new int[](vectorLength);
            
            // scaling
            for (i = 0; i < keyLen; i++) {
                newUpdate[i] = update[i] * numData;
            }

            // summation
            for (i = 0; i < keyLen; i++) {
                weights[key][i] = weights[key][i] + newUpdate[i];
            }
        } else {
            for (i = 0; i < keyLen; i++) {
                weights[key][i] = update[i];
            }
            if (weights[key].length == vectorLength) {
                moreThanOne = true;
            }
        }
        numberOfResponses++;
        emit ResponseReceived(numberOfResponses);
        return weights[key];
    }

    // function inverseScale()
    //     external returns (bool)
    //     // check against threshold
    // {
    //     uint i;
    //     uint j;
    //     uint keyLen = keyList.length;
    //     for (i = 0; i < keyLen; i++) {
    //         for (j = 0; j < vectorLength; j++) {
    //             weights[keyList[i]][j] = weights[keyList[i]][j] / int(totalNumData);
    //         }
    //     }
    //     return true;
    // }
}
