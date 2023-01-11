import { HardhatRuntimeEnvironment } from "hardhat/types";
import { DeployFunction } from "hardhat-deploy/types";

const func: DeployFunction = async function (hre: HardhatRuntimeEnvironment) {
  const { deployments, getNamedAccounts } = hre;
  const { deploy } = deployments;

  const { deployer } = await getNamedAccounts();

  const ExampleContract = await deployments.get("ExampleContract");

  const exampleFactory = await deploy("ExampleFactory", {
    from: deployer,
    args: [[deployer], ExampleContract.address],
    log: true,
    autoMine: true, // speed up deployment on local network (ganache), no effect on live networks
  });

  console.log('Deployed ExampleContract to:', exampleFactory.address)
};
export default func;
func.tags = ["ExampleFactory"];
