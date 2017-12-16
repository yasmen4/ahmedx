docker-arch-xmrstak
==========================

Docker image for an ArchLinux provisionned with XMR-Stak, a universal Stratum
pool miner. It is compiled to support only CPU mining with no developer fee.

Test it easily with:

    # Get the image
    docker pull sbernard/arch-xmrstak
    # Run it
    docker run -d --name axs sbernard/arch-xmrstak
    # Open a shell in it
    docker exec -it axs -o 'pool' -u 'wallet' -p 'pwd'
    # Kill and remove the container
    docker kill axs; docker rm axs
