{
    c: (.clusters[]),
    ctx: (.contexts[]),
    u: (.users[])
}
| select(.ctx.context.user==.u.name and .ctx.context.cluster==.c.name)
| { 
    user: .u.name, 
    tokenfile: .u.user.tokenFile, 
    cluster: .c.name, 
    server:  .c.cluster.server,
    context: .ctx.name,
}
| .user + "\n" + .tokenfile + "\n" + .cluster + "\n" + .server + "\n" + .context + "\n---"