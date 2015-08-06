#!/usr/bin/env python2
import github3
import optparse
import sys

def parse_assets (raw_assets):
    assets = []
    for raw_asset in raw_assets:
        tmp = raw_asset.split (':')
        assets.append ({
            'name': tmp[0],
            'path': ':'.join (tmp[1:])})
    return assets

def read_file (path):
    with open (path) as f:
        return f.read ()

def create_release (release_info):
    user = release_info['user']
    password = release_info['pass']
    gh = github3.login (user, password)
    repo = gh.repository (user, release_info['repo'])
    release = repo.create_release (
        release_info['tag'], release_info['commitish'],
        release_info['name'], release_info['body'],
        release_info['draft'], release_info['pre_release'])
    for asset in release_info['assets']:
        release.upload_asset (
            # TODO: add parameter for content_type
            'application/octet-stream',
            asset['name'],
            read_file (asset['path']))
    return release

def main():
    args = optparse.OptionParser (
            usage='github_upload.py -d -p -c COMMITISH [-a ASSET]...'
                  ' USER PASS REPO TAG NAME BODY')
    args.add_option ('-d', '--draft', dest='draft',
            action='store_true', default=False,
            help='Create a draft release')
    args.add_option ('-p', '--pre-release', dest='pre_release',
            action='store_true', default=False,
            help='Mark the created release as a pre-release')
    args.add_option ('-c', '--commitish', dest='commitish',
            help='Make a new tag from the given COMMITISH')
    args.add_option ('-a', dest='assets', metavar='ASSET',
            action='append', default=[],
            help='Add ASSET to the list of assets attached to the release; '
                 'may be specified many times. '
                 'ASSET should follow the format [name]:[path]')
    (options, rest) = args.parse_args ()
    if len(rest) < 6:
        args.error ('USER, PASS, REPO, TAG, NAME or BODY not specified')

    release = create_release (
        { 'user': rest[0],
          'pass': rest[1],
          'repo': rest[2],
          'tag': rest[3],
          'name': rest[4],
          'body': rest[5],
          'draft': options.draft,
          'pre_release': options.pre_release,
          'commitish': options.commitish,
          'assets': parse_assets (options.assets)})

    print 'Created release %s' % release.name
    print 'URL : %s' % release.url
    print 'TAG : %s' % release.tag_name
    print 'BODY: %s' % release.body
    print 'Assets:'
    for asset in release.assets ():
        print '\t%s: %s' % (asset.name, asset.url)

    return 0

if __name__ == '__main__':
    sys.exit (main ())

# vim: set et ts=4:
