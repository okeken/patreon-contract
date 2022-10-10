//SPDX-License-Identifier: Unlicense
pragma solidity 0.8.17;

contract Patreon {
    // Event to emit when tere is a new subscriber.
    event NewSubscriber(address indexed from, uint256 timestamp, SubPlans plan);
    enum SubPlans {
        basic,
        standard,
        premium
    }

    error SubPriceError(uint256 payment, SubPlans plan);
    string public CHANNEL_NAME;
    uint256 constant ACCESS_DURATION = 30 days;

    // Subscriber struct.
    struct Subscriber {
        address from;
        uint256 lastSubTime;
        SubPlans currentPlan;
        bool expiredSub;
        string name;
    }

    struct PlanPrice {
        SubPlans plan;
        uint256 price;
    }

    mapping(address => Subscriber) public subscriberDeet;
    mapping(SubPlans => PlanPrice) public priceDeet;
    // Address of contract deployer. Marked payable so that
    // we can withdraw to this address later.
    address payable Owner;

    // List of all subscribers to the channel.
    Subscriber[] subscribers;
    PlanPrice[] priceList;

    // modifiers

    modifier onlyOwner() {
        require(Owner == msg.sender, "not owner");
        _;
    }

    modifier validatePlan(SubPlans plan_) {
        PlanPrice memory currentPlan = priceDeet[plan_];

        if (currentPlan.price != msg.value) {
            revert SubPriceError(msg.value, plan_);
        }

        _;
    }

    constructor(string memory channel_name) {
        // Store the address of the deployer as a payable address.
        // When we withdraw funds, we'll withdraw here.
        Owner = payable(msg.sender);
        CHANNEL_NAME = channel_name;

        // // Plans Price
        priceDeet[SubPlans.basic] = PlanPrice(SubPlans.basic, 0.01 ether);
        priceDeet[SubPlans.standard] = PlanPrice(SubPlans.standard, 0.02 ether);
        priceDeet[SubPlans.premium] = PlanPrice(SubPlans.premium, 0.03 ether);

        priceList.push(PlanPrice(SubPlans.basic, 0.01 ether));
        priceList.push(PlanPrice(SubPlans.standard, 0.02 ether));
        priceList.push(PlanPrice(SubPlans.standard, 0.02 ether));
    }

    /**
     * @dev fetches all stored subscribers
     */
    function getSubscribers() public view returns (Subscriber[] memory) {
        return subscribers;
    }

    function _getStatus() private view returns (bool) {
        Subscriber memory sub = subscriberDeet[msg.sender];
        return !(sub.expiredSub);
    }

    /**
     * @param plan_ subscription plan
     */
    function subscribe(SubPlans plan_, string memory name_)
        public
        payable
        validatePlan(plan_)
    {
        require(!(_getStatus()), "you are already subscribed");
        Subscriber memory sub = Subscriber(
            msg.sender,
            block.timestamp,
            plan_,
            true,
            name_
        );

        subscriberDeet[msg.sender] = sub;
        // Add the subscriber to storage!
        subscribers.push(sub);

        // Emit a NewSubscriber event with details about the subscriber.
        emit NewSubscriber(msg.sender, block.timestamp, plan_);
    }

    function accessContent() public returns (bool) {
        Subscriber storage sub = subscriberDeet[msg.sender];
        if ((block.timestamp - sub.lastSubTime) > ACCESS_DURATION) {
            sub.expiredSub = true;
        }
        return _getStatus();
    }

    /**
     * @dev send the entire balance stored in this contract to the Owner
     */
    function withdrawFunds() public onlyOwner {
        require(Owner.send(address(this).balance));
    }

    function changePrice(SubPlans plan_, uint256 amount_)
        public
        onlyOwner
        returns (uint256)
    {
        PlanPrice storage plan = priceDeet[plan_];

        plan.price = amount_;

        return amount_;
    }
}
