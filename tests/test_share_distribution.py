from itertools import count
from brownie import Wei, reverts
import random
import brownie

def test_share_distro(chain, interface, accounts, Contract, Sharer):
    sms = '0x16388463d60FFE0661Cf7F1f31a7D658aC790ff7'
    gspoosi = '0x0C703068a36D7D2199B28B67422B33Ce627B87F6'
    dmi = '0x0D77b4C6916BA6dF46dCbc4809C204dA9089FEE2'

    samdev = accounts.at('0xC3D6880fD95E06C816cB030fAc45b3ffe3651Cb0', force=True)
    
    sharer = samdev.deploy(Sharer)

    contributorsEx = [250,250,250]

    contributorA = [sms, gspoosi, dmi]

    sharer.setContributors(contributorsEx,contributorA, {'from': samdev} )

    yshare = interface.ERC20('0x19d3364a399d251e894ac732651be8b0e4e85001')

    yshare.transfer(sharer, yshare.balanceOf(samdev), {'from': samdev})
    print("Sam bal: ", yshare.balanceOf(samdev))
    assert yshare.balanceOf(samdev) == 0
    print("Sharer bal: ", yshare.balanceOf(sharer)/1e18)

    sharer.distribute(yshare, {'from': samdev})
    print("Sam bal after dis: ", yshare.balanceOf(samdev)/1e18)
    print("gspoosi bal: ", yshare.balanceOf(gspoosi)/1e18)
    assert yshare.balanceOf(gspoosi) == yshare.balanceOf(dmi)
    assert yshare.balanceOf(gspoosi) == yshare.balanceOf(sms)