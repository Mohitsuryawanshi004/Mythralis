// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

contract Mythralis {
    address public immutable guardian;
    uint256 public totalSouls;

    struct Soul {
        string name;           // e.g., "Aeloria the Voidwalker"
        string essence;        // e.g., "Eternal Flame", "Shadowborn"
        uint256 power;
        uint256 awakenedAt;
        bool isImmortal;       // Legendary souls
    }

    mapping(address => Soul) public souls;

    event SoulAwakened(address indexed soul, string name, string essence, bool isImmortal);
    event PowerSacrificed(address indexed soul, uint256 ethBurned, uint256 powerGained);
    event LegendBorn(address indexed soul, string name);

    constructor() {
        guardian = msg.sender;
    }

    // Core Function 1 – Awaken your eternal soul (one-time per address)
    function awaken(string calldata _name, string calldata _essence, bool _isImmortal) external {
        require(bytes(souls[msg.sender].name).length == 0, "Soul already awakened");
        require(bytes(_name).length > 0 && bytes(_essence).length > 0, "Name & essence required");

        uint256 basePower = _isImmortal ? 10_000 : 1_000;

        souls[msg.sender] = Soul({
            name: _name,
            essence: _essence,
            power: basePower,
            awakenedAt: block.timestamp,
            isImmortal: _isImmortal
        });

        totalSouls++;

        emit SoulAwakened(msg.sender, _name, _essence, _isImmortal);

        if (_isImmortal) {
            emit LegendBorn(msg.sender, _name);
        }
    }

    // Core Function 2 – Sacrifice ETH to permanently increase your soul's power
    function sacrificeForPower() external payable {
        Soul storage soul = souls[msg.sender];
        require(bytes(soul.name).length > 0, "Must awaken soul first");
        require(msg.value >= 0.001 ether, "Minimum sacrifice: 0.001 ETH");

        // 0.001 ETH ≈ 100 power (scalable with adoption)
        uint256 powerGained = (msg.value * 100_000) / 1 ether;

        soul.power += powerGained;

        emit PowerSacrificed(msg.sender, msg.value, powerGained);
    }

    // Core Function 3 – Guardian inscribes an eternal prophecy (for lore, events, or future NFT drops)
    function inscribeProphecy(uint256 prophecyId, string calldata prophecy) external {
        require(msg.sender == guardian, "Only Guardian may speak prophecy");
        // In a full version this could emit an event or store in a mapping
        emit ProphecyInscribed(prophecyId, prophecy, block.timestamp);
    }

    event ProphecyInscribed(uint256 indexed id, string prophecy, uint256 timestamp);

    // View function
    function getSoul(address addr) external view returns (Soul memory) {
        return souls[addr];
    }
}
