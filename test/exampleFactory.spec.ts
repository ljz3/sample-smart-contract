import { ethers } from "hardhat";
import { loadFixture } from "@nomicfoundation/hardhat-network-helpers";
import { assert, expect } from "chai";
import "@nomicfoundation/hardhat-toolbox";
import { ExampleContract, ExampleFactory } from "../typechain-types";
import { SignerWithAddress } from "@nomiclabs/hardhat-ethers/signers";

describe("ExampleFactory", function () {
  let factory: ExampleFactory;
  let baseExampleContract: ExampleContract;
  let signers: {
    admin1: SignerWithAddress;
    admin2: SignerWithAddress;
    admin3: SignerWithAddress;
    user1: SignerWithAddress;
    user2: SignerWithAddress;
  };

  before(async function () {
    signers = { ...(await getSignersHelper()) };
  });

  beforeEach(async function () {
    const BaseExampleContract = await ethers.getContractFactory(
      "ExampleContract",
    );
    baseExampleContract = await BaseExampleContract.deploy();
    const Factory = await ethers.getContractFactory("ExampleFactory");
    factory = await Factory.deploy(
      [signers.admin1.address, signers.admin2.address, signers.admin3.address],
      baseExampleContract.address,
    );
  });

  describe("Factory Deployment", () => {
    describe("Clone Deployment", () => {
      it("Clone contract deployed", async () => {
        const salt = getRandomSalt();
        const callData = ethers.utils.defaultAbiCoder.encode(
          ["address[]"],
          [[signers.admin1.address]],
        );
        let tx = await factory.deployDeterministicClone(salt, callData);

        const receipt = await tx.wait();

        const event = receipt.events?.find(
          (ev) => ev.event === "ExampleCloneDeployed",
        );

        const contract = baseExampleContract
          //@ts-ignore
          .attach(event.args[0])
          .connect(signers.admin1);

        expect(contract.address).to.not.be.null;
      });

      it("Clone contract has working function", async () => {
        const salt = getRandomSalt();
        const callData = ethers.utils.defaultAbiCoder.encode(
          ["address[]"],
          [[signers.admin1.address]],
        );
        let tx = await factory.deployDeterministicClone(salt, callData);

        const receipt = await tx.wait();

        const event = receipt.events?.find(
          (ev) => ev.event === "ExampleCloneDeployed",
        );

        const contract = baseExampleContract
          //@ts-ignore
          .attach(event.args[0])
          .connect(signers.admin1);

        const val = await contract.CONTRACT_NAME();

        expect(val).to.equal("Example Contract");
      });
    });

    describe("Proxy Deployment", () => {
      it("Proxy contract deployed", async () => {
        const salt = getRandomSalt();
        const callData = ethers.utils.defaultAbiCoder.encode(
          ["address[]"],
          [[signers.admin1.address]],
        );
        let tx = await factory.deployDeterministicUpgradableProxy(salt, callData);

        const receipt = await tx.wait();

        const event = receipt.events?.find(
          (ev) => ev.event === "ExampleCloneDeployed",
        );

        const contract = baseExampleContract
          //@ts-ignore
          .attach(event.args[0])
          .connect(signers.admin1);

        expect(contract.address).to.not.be.null;
      });

      it("Proxy contract has working function", async () => {
        const salt = getRandomSalt();
        const callData = ethers.utils.defaultAbiCoder.encode(
          ["address[]"],
          [[signers.admin1.address]],
        );
        let tx = await factory.deployDeterministicUpgradableProxy(salt, callData);

        const receipt = await tx.wait();

        const event = receipt.events?.find(
          (ev) => ev.event === "ExampleCloneDeployed",
        );

        const contract = baseExampleContract
          //@ts-ignore
          .attach(event.args[0])
          .connect(signers.admin1);

        const val = await contract.CONTRACT_NAME();

        expect(val).to.equal("Example Contract");
      });
    });
  });

  // Helper function to get a random salt
  const getRandomSalt = () => {
    return ethers.utils.randomBytes(20);
  };

  // Helper function to set all signers used in this test suite
  const getSignersHelper = async () => {
    const [admin1, admin2, admin3, user1, user2] = await ethers.getSigners();

    return {
      admin1,
      admin2,
      admin3,
      user1,
      user2,
    };
  };
});
